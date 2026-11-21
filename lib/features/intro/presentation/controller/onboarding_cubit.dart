import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/controllers/safe_emit.dart';

import '../../../../../core/helper/app_navigator.dart';
import '../../../../../core/network/local/cache/cache_helper.dart';
import '../../../../../core/network/local/cache/cache_keys.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../data/models/onboarding_model.dart';

part 'onboarding_state.dart';

/// Drives the onboarding carousel.
///
/// The [PageController] lives here, is exposed to the screen as a final field,
/// and is disposed in [close] — the screen owns nothing.
class OnboardingCubit extends Cubit<OnboardingState> with SafeEmit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  static OnboardingCubit get(BuildContext ctx) => BlocProvider.of(ctx);

  /// Owned here, never created in the widget tree.
  final PageController controller = PageController();

  /// The page currently showing.
  int index = 0;

  /// The slides.
  ///
  /// A getter, not a stored list: the legacy version calls `tr()` in a field
  /// initialiser, so the copy is translated once when the cubit is built and
  /// never again — switching language leaves the slides in the old one.
  List<OnboardingModel> get onBoarding => <OnboardingModel>[
    OnboardingModel(
      image: 'assets/svg/onboard1.svg',
      title: 'onboarding.item1.title'.tr(),
      desc: 'onboarding.item1.desc'.tr(),
    ),
    OnboardingModel(
      image: 'assets/svg/onboard2.svg',
      title: 'onboarding.item2.title'.tr(),
      desc: 'onboarding.item2.desc'.tr(),
    ),
    OnboardingModel(
      image: 'assets/svg/onboard3.svg',
      title: 'onboarding.item3.title'.tr(),
      desc: 'onboarding.item3.desc'.tr(),
    ),
  ];

  /// Whether the visible slide is the last one.
  bool get isLastPage => index >= onBoarding.length - 1;

  /// Records the page the carousel settled on.
  void updateIndex(int value) {
    if (value == index) return;
    index = value;
    emit(OnboardingIndexChanged(value));
  }

  /// Advances one slide, or finishes when already on the last.
  Future<void> nextTap() async {
    if (isLastPage) {
      await skip();
      return;
    }
    await controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  /// Marks onboarding as seen and moves on.
  ///
  /// The flag is written before navigating, so a user who kills the app during
  /// the transition does not see onboarding a second time.
  Future<void> skip() async {
    await CacheHelper.save(CacheKeys.firstUse, false);
    AppNavigator.remove(const SignInScreen());
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
