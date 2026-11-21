import 'package:flutter/material.dart';

import '../../style/app_size.dart';

class CustomApplePayButton extends StatelessWidget {
  const CustomApplePayButton({
    super.key,
    required this.onTap,
    this.width,
    this.height,
    this.borderRadius,
    this.loading = false,
  });

  final bool loading;
  final double? width;
  final double? height;
  final Function()? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSize.getHeight(8)),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? AppSize.getHeight(48),
        padding: AppSize.padding(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSize.getSize(8)),
          color: Colors.black, // Standard Apple Pay button background
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: AppSize.getSize(26),
                  height: AppSize.getSize(26),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apple, // Uses standard material apple icon
                      color: Colors.white,
                      size: AppSize.getSize(24),
                    ),
                    SizedBox(width: AppSize.getWidth(4)),
                    Text(
                      'Pay',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSize.font(20),
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: '.SF Pro Display', // Recommended font for Apple Pay if available
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
