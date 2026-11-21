/// One onboarding slide.
class OnboardingModel {
  OnboardingModel({
    required this.desc,
    required this.title,
    required this.image,
  });

  /// Heading. Already translated.
  final String title;

  /// Illustration asset path.
  final String image;

  /// Body copy. Already translated.
  final String desc;
}
