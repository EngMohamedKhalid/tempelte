import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// A solid rounded square holding a white icon (F26).
///
/// Leads a section title, a counter or a list tile, so a section reads by
/// colour as well as by its words. Pass a tone's `solid` as [color]: white on
/// every solid clears 4.5:1 (`contrast_test.dart`).
class IconChip extends StatelessWidget {
  const IconChip({
    required this.color,
    required this.icon,
    this.size = 32,
    super.key,
  });

  final Color color;
  final IconData icon;

  /// The chip's side, before `AppSize` scaling.
  final double size;

  @override
  Widget build(BuildContext context) {
    final double side = AppSize.getSize(size);
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          AppSize.getSize(AppRadius.small + 2),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: side * 0.53, color: AppColors.white),
    );
  }
}
