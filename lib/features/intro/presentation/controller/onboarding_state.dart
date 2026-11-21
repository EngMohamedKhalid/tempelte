part of 'onboarding_cubit.dart';

@immutable
sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// The visible page changed. [index] is the page now showing.
final class OnboardingIndexChanged extends OnboardingState {
  const OnboardingIndexChanged(this.index);

  final int index;
}
