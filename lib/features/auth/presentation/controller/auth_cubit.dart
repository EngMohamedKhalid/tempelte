import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/controllers/safe_emit.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../core/helper/app_helper.dart';
import '../../../../../core/helper/app_navigator.dart';
import '../../../../../core/helper/app_toast.dart';
import '../../../../../core/network/errors/failure.dart';
import '../../../../../core/network/local/cache/cache_helper.dart';
import '../../../../../core/network/local/cache/cache_keys.dart';
import '../../../../../core/shared/enums/user_role.dart';
import '../../../../../core/shared/features/user/controllers/user_cubit.dart';
import '../../../../../core/shared/features/user/models/user_model.dart';
import '../../../intro/presentation/screens/splash_screen.dart';
import '../../data/params/forget_param.dart';
import '../../data/params/reset_param.dart';
import '../../data/params/sign_in_param.dart';
import '../../data/params/sign_up_param.dart';
import '../../data/params/verify_otp_param.dart';
import '../../data/repo/auth_repo.dart';
import '../../data/repo/auth_repo_impel.dart';
import '../screens/forget_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/verification_screen.dart';

part 'auth_state.dart';

/// Every auth flow: sign in, register, confirm a number, recover a password.
///
/// One cubit for the whole feature, as in the legacy app. Each screen provides
/// its own instance, so the controllers below belong to the screen that is on
/// top and nothing leaks between them.
class AuthCubit extends Cubit<AuthState> with SafeEmit<AuthState> {
  AuthCubit({AuthRepo? repo})
    : _repo = repo ?? AuthRepoImpel(),
      super(const AuthInitial());

  static AuthCubit get(BuildContext ctx) => BlocProvider.of(ctx);

  /// How long before another OTP may be requested.
  ///
  /// Three minutes, matching the legacy app's 180000 ms timer.
  static const int resendSeconds = 180;

  final AuthRepo _repo;

  // ── Form keys ────────────────────────────────────────────────────────────
  // One per form. A single shared key would validate whichever form was built
  // last, which is how a screen ends up submitting an empty field.
  final GlobalKey<FormState> signInKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgetKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────────────
  // Created here, disposed in close(). Never built in the widget tree.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  /// pin_code_fields 10 wraps the text controller and focus node together.
  final PinInputController codeController = PinInputController();

  /// The parsed number, kept so the country code travels with it.
  PhoneNumber? phone;

  bool obscurePassword = true;
  bool obscureConfirm = true;

  Timer? _timer;
  int secondsLeft = resendSeconds;

  /// Whether a new code may be requested yet.
  bool get canResend => secondsLeft <= 0;

  /// Records the number as the field parses it.
  void onPhoneChanged(PhoneNumber value) => phone = value;

  /// Clears the number when the country changes.
  ///
  /// Without this a number typed for one country is submitted with another's
  /// dialling code.
  void onCountryChanged(Country value) {
    phone = null;
    phoneController.clear();
    emit(const AuthInitial());
  }

  /// Shows or hides the password.
  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    _emitObscure();
  }

  /// Shows or hides the confirmation.
  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    _emitObscure();
  }

  // ── Sign in ─────────────────────────────────────────────────────────────

  /// Validates and signs in.
  Future<void> signIn() async {
    await CacheHelper.remove(CacheKeys.guest);
    AppHelper.closeKeyboard();
    if (!(signInKey.currentState?.validate() ?? false)) return;

    emit(const AuthLoading());
    final result = await _repo.signIn(
      SignInParam(phone: fullNumber, password: passwordController.text),
    );

    result.fold(_fail, (UserModel user) {
      final UserRoleEnum? role = getUserRoleEnum(user.role);
      if (role == null) {
        // An account this app cannot serve. A plain message beats a shell it
        // has no business in — the legacy router sends anything it does not
        // recognise to the driver board.
        _fail(ForbiddenFailure('sign_in.unsupported_role'.tr()));
        return;
      }
      AppToast.success('sign_in.login_success'.tr());
      emit(AuthSignedIn(role: role));
      // Populate the shared user before routing, so whatever lands next can
      // read it without fetching again.
      _seedUser(user);
      // Splash re-resolves the destination rather than repeating the
      // role-to-screen decision here. The legacy app spreads that decision
      // across three files, which is how they drift apart.
      AppNavigator.remove(const SplashScreen());
    });
  }

  /// Signs in on the shared guest account so the app can be browsed without
  /// registering.
  ///
  /// **The credentials below ship in the binary and can be read out of the
  /// APK.** They are a real, password-authenticated account on the production
  /// system, not an anonymous session. Ported deliberately, on the owner's
  /// decision, to match the legacy app; the alternative is
  /// `POST auth/guest`, which the backend already serves.
  Future<void> signInGuest() async {
    AppHelper.closeKeyboard();
    emit(const AuthGuestLoading());

    final result = await _repo.signIn(
      SignInParam(phone: _guestPhone, password: _guestPassword),
    );

    await result.fold(
      (Failure failure) async => _fail(failure),
      (UserModel user) async {
        await CacheHelper.save(CacheKeys.guest, true);
        emit(AuthSignedIn(role: getUserRoleEnum(user.role) ?? UserRoleEnum.customer));
        AppNavigator.remove(const SplashScreen());
      },
    );
  }

  // ── Register ────────────────────────────────────────────────────────────

  /// Validates and registers, then goes on to confirm the number.
  ///
  /// Ordinary registration: the form is submitted first and the number is
  /// confirmed afterwards, as the legacy app does it.
  /// Starts registration by proving the number is reachable.
  ///
  /// **Nothing is created yet.** `POST auth/register` requires a
  /// `verification_token`, so the order is: send a code, verify it, then
  /// register with the token this produces. The form's answers are held here
  /// in the controllers until [verify] completes the account.
  ///
  /// The first build of this posted the form and confirmed the number
  /// afterwards, the way the legacy app does. The v2 server 422s that request.
  Future<void> signUp() async {
    await CacheHelper.remove(CacheKeys.guest);
    AppHelper.closeKeyboard();
    if (!(signUpKey.currentState?.validate() ?? false)) return;

    emit(const AuthLoading());
    final String number = fullNumber;
    final result = await _repo.resendCode(
      VerifyOtpParam(phone: number, purpose: OtpPurpose.register),
    );

    result.fold(_fail, (_) {
      emit(const AuthRegistered());
      AppNavigator.replace(
        VerificationScreen(phone: number, purpose: OtpPurpose.register),
      );
    });
  }

  /// Creates the account, once the number has been verified.
  ///
  /// Called only from [verify], with the token that verification returned.
  Future<void> _completeRegistration(String verificationToken) async {
    final result = await _repo.signUp(
      SignUpParam(
        verificationToken: verificationToken,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );

    result.fold(_fail, (_) {
      AppToast.success('sign_up.success'.tr());
      // Registration may hand back a session. Splash re-resolves either way:
      // with one it routes to the customer's shell, without one to sign in.
      AppNavigator.remove(const SplashScreen());
    });
  }

  // ── Verify ──────────────────────────────────────────────────────────────

  /// Starts the resend countdown. Called when a verification screen opens.
  void startCountdown() {
    _timer?.cancel();
    secondsLeft = resendSeconds;
    emit(AuthOtpTicked(secondsLeft: secondsLeft));

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      secondsLeft -= 1;
      if (!isClosed) emit(AuthOtpTicked(secondsLeft: secondsLeft));
      if (secondsLeft <= 0) timer.cancel();
    });
  }

  /// Checks the entered code.
  Future<void> verify({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {
    AppHelper.closeKeyboard();
    final String code = codeController.text.trim();
    if (code.length < 4) {
      AppToast.error('validators.OTP.length'.tr());
      return;
    }

    emit(const AuthLoading());
    final result = await _repo.verifyCode(
      VerifyOtpParam(phone: phoneNumber, purpose: purpose, code: code),
    );

    await result.fold((Failure failure) async => _fail(failure), (
      String token,
    ) async {
      emit(AuthVerified(verificationToken: token.isEmpty ? null : token));

      if (purpose == OtpPurpose.reset) {
        // The phone travels too: the legacy reset endpoint identifies the
        // account by number, and only the newer one takes a token.
        AppNavigator.replace(
          ResetPasswordScreen(verificationToken: token, phone: phoneNumber),
        );
        return;
      }

      if (purpose == OtpPurpose.register) {
        if (token.isEmpty) {
          // Verification succeeded but minted nothing to register with. Better
          // a plain message than a request that cannot succeed.
          _fail(ServerFailure('sign_up.no_verification_token'.tr()));
          return;
        }
        await _completeRegistration(token);
        return;
      }

      AppToast.success('sign_up.success'.tr());
      AppNavigator.remove(const SignInScreen());
    });
  }

  /// Requests a fresh code, if the countdown has run out.
  Future<void> resend({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {
    if (!canResend) return;

    emit(const AuthLoading());
    final result = await _repo.resendCode(
      VerifyOtpParam(phone: phoneNumber, purpose: purpose),
    );

    result.fold(
      // A 429 here is ordinary, not exceptional: the endpoint is rate limited
      // per phone and per IP by design.
      _fail,
      (_) {
        startCountdown();
        AppToast.success('verification.resend'.tr());
      },
    );
  }

  // ── Recover ─────────────────────────────────────────────────────────────

  /// Sends a reset code and moves on to entering it.
  Future<void> sendResetCode() async {
    AppHelper.closeKeyboard();
    if (!(forgetKey.currentState?.validate() ?? false)) return;

    emit(const AuthLoading());
    final String number = fullNumber;
    final result = await _repo.forgetPassword(ForgetParam(phone: number));

    result.fold(_fail, (_) {
      emit(const AuthCodeSent());
      AppNavigator.push(
        VerificationScreen(phone: number, purpose: OtpPurpose.reset),
      );
    });
  }

  /// Sets a new password, proving ownership with [verificationToken].
  Future<void> resetPassword({
    required String phoneNumber,
    String? verificationToken,
  }) async {
    AppHelper.closeKeyboard();
    if (!(resetKey.currentState?.validate() ?? false)) return;

    emit(const AuthLoading());
    final result = await _repo.resetPassword(
      ResetParam(
        phone: phoneNumber,
        verificationToken: verificationToken,
        password: passwordController.text,
        passwordConfirmation: confirmController.text,
      ),
    );

    result.fold(_fail, (_) {
      emit(const AuthPasswordReset());
      AppToast.success('recovery.reset.success'.tr());
      AppNavigator.remove(const SignInScreen());
    });
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  /// Opens registration.
  void openSignUp() => AppNavigator.push(const SignUpScreen());

  /// Opens password recovery.
  void openForgetPassword() => AppNavigator.push(const ForgetPasswordScreen());

  /// Back to sign in.
  void openSignIn() => AppNavigator.pop();

  // ── Internals ───────────────────────────────────────────────────────────

  /// Shared guest account, carried over from the legacy app verbatim.
  ///
  /// **+962 is Jordan, and that is correct.** The account really is a Jordanian
  /// number — verified by signing in against the live API. It was transcribed
  /// as +966 (Saudi) when this was ported, and one digit is the whole reason
  /// guest sign-in returned "These credentials do not match our records".
  static const String _guestPhone = '+962790888700';
  static const String _guestPassword = 'password';

  /// The number with its country code, as the API wants it.
  String get fullNumber {
    final PhoneNumber? value = phone;
    if (value == null) return phoneController.text.trim();
    return '${value.countryCode}${value.number}';
  }

  /// Seeds the shared [UserCubit] from the user sign-in just returned.
  ///
  /// Not a refetch. `POST auth/login` answers with `{token, user}`, so calling
  /// `getUser()` here asked `/me` for what was already in hand — and splash,
  /// which routes on the answer, then asked a third time. One request now
  /// where there were three.
  void _seedUser(UserModel user) {
    final BuildContext? ctx = AppNavigator.key.currentContext;
    if (ctx == null) return;
    UserCubit.get(ctx).setUser(user);
  }

  void _fail(Failure failure) {
    AppToast.error(failure.errMessage);
    emit(AuthFailed(failure));
  }

  void _emitObscure() => emit(
    AuthObscureChanged(
      obscurePassword: obscurePassword,
      obscureConfirm: obscureConfirm,
    ),
  );

  @override
  Future<void> close() {
    _timer?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    codeController.dispose();
    return super.close();
  }
}
