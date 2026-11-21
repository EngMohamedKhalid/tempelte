import 'package:flutter/material.dart';

import '../../constant/app_assets.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import 'custom_svg.dart';

class AuthAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppbar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          titleSpacing: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: AppSize.font(16),
            fontWeight: FontWeight.w400,
            fontFamily: 'Tajawal',
            color: AppColors.typographyHeadingLight,
          ),
          backgroundColor: AppColors.primary,
        ),
      ),
      child: AppBar(
        centerTitle: true,
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        actions: [
          CustomSvg(
            svg: AppSvg.logo,
            width: AppSize.getWidth(85),
            height: AppSize.getHeight(44),
          ),
          SizedBox(width: AppSize.getWidth(24)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
