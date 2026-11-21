import 'package:flutter/material.dart';

import '../../style/app_size.dart';

/// A themed switch: track colour (on/off) comes from `ThemeData.switchTheme`
/// (Task 5), not from this widget.
class CustomSwitch extends StatelessWidget {
  /// Creates a themed switch.
  const CustomSwitch({super.key, required this.value, this.onChange});

  /// Whether the switch is on.
  final bool value;

  /// Called when the switch is toggled.
  final Function(bool)? onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSize.getWidth(44),
      height: AppSize.getHeight(24),
      child: Switch(
        value: value,
        onChanged: onChange,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
