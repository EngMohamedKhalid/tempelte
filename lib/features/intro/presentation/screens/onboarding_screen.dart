import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/widgets/hero_background.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../controller/onboarding_cubit.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/onboarding_counter.dart';
import '../widgets/onboarding_progress.dart';

/// First-run onboarding.
///
/// The illustration rides on a rounded navy card, the words sit on the light
/// page below with a slide counter (F26 round 3, the flow's new concept).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        buildWhen: (previous, current) => current is OnboardingIndexChanged,
        builder: (context, state) {
          final OnboardingCubit cubit = OnboardingCubit.get(context);
          return Scaffold(
            // F26 round 3: the signed-out flow's new concept — a light page,
            // the art on a rounded navy card.
            backgroundColor: AppColors.backgroundPrimary,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: AppSize.padding(horizontal: AppSpacing.page, top: AppSpacing.gapS),
                      child: ClipRRect(
                        key: const Key('onboarding-hero'),
                        borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.card * 2)),
                        child: HeroBackground(
                          child: PageView.builder(
                            controller: cubit.controller,
                            itemCount: cubit.onBoarding.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: cubit.updateIndex,
                            itemBuilder: (_, i) => OnboardingArtwork(onboarding: cubit.onBoarding[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: AppSize.padding(
                        horizontal: AppSpacing.page,
                        top: AppSpacing.gapXl,
                        bottom: AppSpacing.gapM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OnboardingCounter(index: cubit.index, count: cubit.onBoarding.length),
                              SizedBox(width: AppSize.getWidth(AppSpacing.gapM)),
                              Expanded(
                                child: OnboardingProgress(
                                  index: cubit.index,
                                  count: cubit.onBoarding.length,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSize.getHeight(AppSpacing.gapXl)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: OnboardingCopy(onboarding: cubit.onBoarding[cubit.index]),
                            ),
                          ),
                          OnboardingControls(cubit: cubit),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
