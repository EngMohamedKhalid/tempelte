import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/controllers/safe_emit.dart';

import '../../../../../core/helper/app_navigator.dart';
import '../../../../../core/network/local/cache/cache_helper.dart';
import '../../../../../core/network/local/cache/cache_keys.dart';
import '../../../../../core/shared/enums/user_role.dart';
import '../../../../../core/shared/features/user/controllers/user_cubit.dart';
import '../../../../../core/shared/features/user/models/user_model.dart';
import '../../../profile/presentation/controller/user_session_sync.dart';
import '../../../../user/user_cars/data/models/user_car_model.dart';
import '../../../../user/user_cars/data/repo/user_cars_repo.dart';
import '../../../../user/user_cars/data/repo/user_cars_repo_impel.dart';
import '../../../auth/data/repo/auth_repo.dart';
import '../../../auth/data/repo/auth_repo_impel.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../../user/user_layout/presentation/controller/user_layout_cubit.dart';
import '../../../../user/user_layout/presentation/screens/user_layout_screen.dart';
import '../../../../driver/driver_layout/presentation/screens/staff_layout_screen.dart';
import '../screens/onboarding_screen.dart';

part 'splash_state.dart';

/// Decides where a cold start lands.
///
/// This is the one place the app answers "who is this and what do they see".
/// The legacy version spreads the same decision across three files, runs it
/// from `initState`, and routes any role that is not `user` or `supervisor` to
/// the driver layout.
///
/// It also sleeps for a second on every branch, on top of a `main()` that
/// already waits 300 ms and blocks on a store round-trip. There is no delay
/// here: the work itself is the only thing the user waits for.
///
/// The user it fetches to decide is also handed to the app-wide [UserCubit]
/// ([UserSessionSync]). Before, only sign-in did that, so after a cold start —
/// or a language restart, which is one — the profile header had no user and
/// read "Account" instead of the name.
class SplashCubit extends Cubit<SplashState>
    with SafeEmit<SplashState>, UserSessionSync {
  SplashCubit({AuthRepo? authRepo, UserCarsRepo? carsRepo, this.userCubit})
    : _authRepo = authRepo ?? AuthRepoImpel(),
      _carsRepo = carsRepo ?? UserCarsRepoImpel(),
      super(const SplashInitial());

  /// The session to fill; looked up from the navigator's tree when null.
  @override
  final UserCubit? userCubit;

  static SplashCubit get(BuildContext ctx) => BlocProvider.of(ctx);

  final AuthRepo _authRepo;
  final UserCarsRepo _carsRepo;

  /// Resolves the destination and navigates to it.
  Future<void> resolve() async {
    emit(const SplashResolving());
    AppNavigator.remove(await _destination());
    emit(const SplashResolved());
  }

  /// Works out the screen for the stored session.
  ///
  /// Separated from navigation so the routing contract can be unit-tested
  /// without a navigator.
  @visibleForTesting
  Future<Widget> destination() => _destination();

  Future<Widget> _destination() async {
    final String? token = CacheHelper.get(CacheKeys.token) as String?;

    if (token == null || token.isEmpty) {
      // `first_use` is true until onboarding completes — CacheHelper.init()
      // seeds it true, and OnboardingCubit.skip() writes false. Absent counts
      // as a first run.
      final bool isFirstUse =
          CacheHelper.get(CacheKeys.firstUse) as bool? ?? true;
      return isFirstUse ? const OnboardingScreen() : const SignInScreen();
    }

    final result = await _authRepo.getUser();
    return result.fold(
      // The token did not resolve to a user. Back to sign in — and do not
      // keep a token the server has already rejected.
      (_) {
        CacheHelper.remove(CacheKeys.token);
        return const SignInScreen();
      },
      _screenForUser,
    );
  }

  /// Whether the customer has a car, counted from their cars.
  ///
  /// `GET /me` carries no `car_count` — verified against the live API — so the
  /// count comes from the length of `GET /cars`. A failure here is not the
  /// customer's problem: it resolves to "has cars" so they land on the car
  /// parks rather than being sent to manage a garage the app could not read.
  Future<bool> _hasCar() async {
    final result = await _carsRepo.getCars();
    return result.fold(
      (_) => true,
      (List<UserCarModel> cars) => cars.isNotEmpty,
    );
  }

  /// Maps a user onto their shell.
  ///
  /// An unrecognised role returns the sign-in screen rather than guessing.
  /// `GET /me` only ever sends `customer`, `driver` or `supervisor`, so
  /// anything else means the session is not one this app can serve.
  Future<Widget> _screenForUser(UserModel user) async {
    adoptUser(user);
    final UserRoleEnum? role = getUserRoleEnum(user.role);
    if (role == null) return const SignInScreen();

    if (role.isStaff) {
      // Into the staff shell, on the board. Chat is a tab there for a
      // supervisor and absent for a driver, which is the same permission the
      // legacy encodes in its supervisor-only chat icon.
      return StaffLayoutScreen(isSupervisor: role.canAssignDriver);
    }
    // Into the shell, on the tab that makes sense. A customer with no car
    // cannot book, so they start on their cars — but inside the navigation
    // rather than on a screen with nothing behind it.
    return UserLayoutScreen(
      initialTab: await _hasCar() ? UserTab.home : UserTab.cars,
    );
  }
}
