import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';

/// A labelled radio row.
///
/// Flutter deprecated `Radio.groupValue` and `Radio.onChanged` in favour of a
/// [RadioGroup] ancestor, so the group is declared here and the [Radio] itself
/// only carries its own value. The widget's public API is unchanged, so every
/// caller stays as it was.
class CustomRadio<T> extends StatelessWidget {
  const CustomRadio({
    super.key,
    required this.title,
    required this.value,
    required this.onChange,
    required this.groupValue,
  });

  final String title;
  final T value;
  final T? groupValue;
  final Function(T?) onChange;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChange,
      child: Row(
        children: [
          SizedBox(
            width: AppSize.getSize(24),
            height: AppSize.getSize(24),
            child: Radio<T>(value: value),
          ),
          SizedBox(width: AppSize.getSize(12)),
          Expanded(
            child: InkWell(
              onTap: () => onChange(value),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppSize.font(16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.typographyHeading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
