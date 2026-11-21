part of 'auth_cubit.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The guest sign-in is in flight. Separate from [AuthLoading] so the guest
/// button spins without also disabling the real sign-in button.
final class AuthGuestLoading extends AuthState {
  const AuthGuestLoading();
}

/// A password field's visibility changed. Carries both flags, so the UI never
/// reads a mutable field to find out which.
final class AuthObscureChanged extends AuthState {
  const AuthObscureChanged({
    required this.obscurePassword,
    required this.obscureConfirm,
  });

  final bool obscurePassword;
  final bool obscureConfirm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthObscureChanged &&
          other.obscurePassword == obscurePassword &&
          other.obscureConfirm == obscureConfirm;

  @override
  int get hashCode => Object.hash(obscurePassword, obscureConfirm);
}

/// The resend countdown ticked. Resend is allowed at zero.
final class AuthOtpTicked extends AuthState {
  const AuthOtpTicked({required this.secondsLeft});

  final int secondsLeft;

  bool get canResend => secondsLeft <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthOtpTicked && other.secondsLeft == secondsLeft;

  @override
  int get hashCode => secondsLeft.hashCode;
}

final class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.role});

  final UserRoleEnum role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthSignedIn && other.role == role;

  @override
  int get hashCode => role.hashCode;
}

final class AuthRegistered extends AuthState {
  const AuthRegistered();
}

final class AuthCodeSent extends AuthState {
  const AuthCodeSent();
}

final class AuthVerified extends AuthState {
  const AuthVerified({this.verificationToken});

  /// Set only for a password reset.
  final String? verificationToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthVerified && other.verificationToken == verificationToken;

  @override
  int get hashCode => verificationToken.hashCode;
}

final class AuthPasswordReset extends AuthState {
  const AuthPasswordReset();
}

final class AuthFailed extends AuthState {
  const AuthFailed(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthFailed && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
