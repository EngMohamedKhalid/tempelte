import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';

/// A sentence with a tappable ending, for "Already have an account? Sign in".
///
/// Built as a single wrapping [Wrap] rather than a fixed [Row] so it survives
/// a long translation and either text direction.
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    required this.question,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.typographySubtitle,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: AppSize.padding(horizontal: 6, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
