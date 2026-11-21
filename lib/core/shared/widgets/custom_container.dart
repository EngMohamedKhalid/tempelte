import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.padding,
    this.radius,
    required this.children,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? AppSize.padding(all: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: radius ?? BorderRadius.circular(AppSize.getSize(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class CustomDetailsCard extends StatelessWidget {
  const CustomDetailsCard({
    super.key,
    this.desc,
    this.title,
    this.divider = true,
  });

  final String? title;
  final String? desc;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontSize: AppSize.font(16),
              fontWeight: FontWeight.w700,
              color: AppColors.typographyHeading,
            ),
          ),
        if (desc != null) ...[
          if (title != null) SizedBox(height: AppSize.getHeight(4)),
          Text(
            '$desc',
            style: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w500,
              color: AppColors.typographySubtitle,
            ),
          ),
        ],
        if (divider) Divider(height: AppSize.getHeight(20)),
      ],
    );
  }
}
