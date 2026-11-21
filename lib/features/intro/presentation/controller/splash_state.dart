part of 'splash_cubit.dart';

@immutable
sealed class SplashState {
  const SplashState();
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashResolving extends SplashState {
  const SplashResolving();
}

/// The destination has been decided and navigation has been issued.
final class SplashResolved extends SplashState {
  const SplashResolved();
}
