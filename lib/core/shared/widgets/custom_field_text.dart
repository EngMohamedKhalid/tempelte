import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import 'custom_icon.dart';

/// A text field styled by the theme: border, fill and hint colours come from
/// `ThemeData.inputDecorationTheme` (Task 5), not from this widget.
class CustomFieldText extends StatelessWidget {
  /// Creates a themed text field.
  const CustomFieldText({
    super.key,
    this.title,
    this.hintText,
    this.helperText,
    this.labelText,
    required this.controller,
    this.onSubmit,
    this.padding,
    this.onTap,
    this.onChanged,
    this.iconStart,
    this.iconEnd,
    this.iconEndTap,
    this.minLines,
    this.maxLines,
    this.enabled = true,
    this.validator,
    this.maxLength,
    this.borderColor,
    this.iconColor = false,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.optional = false,
    this.textDirection,
  });

  /// The text editing controller.
  final TextEditingController controller;

  /// Whether [iconStart]/[iconEnd] are tinted with their own colour, rather
  /// than the default subtitle tint.
  final bool iconColor;

  /// Asset name for the leading icon.
  final String? iconStart;

  /// Asset name for the trailing icon.
  final String? iconEnd;

  /// Called when [iconEnd] is tapped.
  final Function()? iconEndTap;

  /// The field's label, shown above the input.
  final String? title;

  /// Shown as the input's floating label.
  final String? labelText;

  /// Placeholder text.
  final String? hintText;

  /// Helper text shown below the input.
  final String? helperText;

  /// The keyboard type; also drives [directionFor] when [textDirection] is
  /// null.
  final TextInputType? keyboardType;

  /// Content padding override.
  final EdgeInsetsGeometry? padding;

  /// Whether the input obscures its text (passwords).
  final bool obscureText;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum number of lines.
  final int? maxLines;

  /// Maximum character count.
  final int? maxLength;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field grabs focus on build.
  final bool autofocus;

  /// Overrides the theme's enabled border colour, when given.
  final Color? borderColor;

  /// Called on tap.
  final Function()? onTap;

  /// Called when the field is submitted.
  final Function(String)? onSubmit;

  /// Called when the field's text changes.
  final Function(String)? onChanged;

  /// Validates the field's value.
  final FormFieldValidator<String>? validator;

  /// Input formatters applied to the field.
  final List<TextInputFormatter>? inputFormatters;

  /// Shows the "optional" tag after the title.
  final bool optional;

  /// Overrides [directionFor]. Leave null to follow the keyboard type.
  ///
  /// `ui.` because easy_localization re-exports intl, whose own
  /// `TextDirection` shadows the framework's.
  final ui.TextDirection? textDirection;

  /// LTR for numbers, phones, emails and dates, whatever the locale — they
  /// are read left to right in Arabic too. Null means "follow the locale".
  static ui.TextDirection? directionFor(TextInputType? type) {
    if (type == null) return null;
    const List<TextInputType> ltr = <TextInputType>[
      TextInputType.phone,
      TextInputType.number,
      TextInputType.emailAddress,
      TextInputType.datetime,
    ];
    return ltr.any((TextInputType t) => t.index == type.index)
        ? ui.TextDirection.ltr
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconTint = AppColors.typographySubtitle;
    Widget? icon(String? asset, {Function()? onTap}) => asset == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomIcon(
                icon: asset,
                onTap: onTap,
                withColor: iconColor,
                width: AppSize.getSize(50),
                color: iconColor ? null : iconTint,
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) ...<Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  title!,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: AppColors.typographyLabel,
                  ),
                ),
              ),
              if (optional) ...<Widget>[
                SizedBox(width: AppSize.getWidth(6)),
                Text(
                  'core.optional'.tr(),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: AppColors.typographySubtitle,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSize.getHeight(AppSpacing.labelGap)),
        ],
        TextFormField(
          maxLength: maxLength,
          // F26 round 3: the cap holds, but no "0/9" counter under the field.
          buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          minLines: minLines ?? 1,
          maxLines: maxLines ?? minLines ?? 1,
          autofocus: autofocus,
          onChanged: onChanged,
          controller: controller,
          obscureText: obscureText,
          onFieldSubmitted: onSubmit,
          keyboardType: keyboardType,
          textDirection: textDirection ?? directionFor(keyboardType),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: enabled ? AppColors.typographyHeading : AppColors.typographySubtitle,
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            fillColor: enabled
                ? null
                : (AppColors.isDark() ? AppColors.navy800 : AppColors.navy50),
            suffixIconConstraints: BoxConstraints(
              minHeight: AppSize.getHeight(40),
              maxHeight: AppSize.getHeight(40),
            ),
            prefixIconConstraints: BoxConstraints(
              minHeight: AppSize.getHeight(40),
              maxHeight: AppSize.getHeight(40),
            ),
            enabledBorder: borderColor == null
                ? null
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.control)),
                    borderSide: BorderSide(color: borderColor!),
                  ),
            contentPadding: padding,
            hintText: hintText ?? labelText ?? '',
            helperText: helperText,
            prefixIcon: icon(iconStart),
            suffixIcon: icon(iconEnd, onTap: iconEndTap),
          ),
        ),
      ],
    );
  }
}
