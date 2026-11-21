import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../style/app_size.dart';

class CustomQrcodeImage extends StatelessWidget {
  const CustomQrcodeImage({
    super.key,
    required this.svgPath,
    this.width,
    this.height,
  });
  final String svgPath;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgPath,
      width: AppSize.getWidth(width ?? 209),
      height: AppSize.getHeight(height ?? 209),
    );
  }
}
