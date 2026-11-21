import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// A single-select dropdown backed by [DropdownButtonFormField].
///
/// **Deprecated.** Every dropdown in the app must be searchable; use
/// [CustomFieldDropdown2] instead. Kept only until legacy call sites migrate.
class CustomFieldDropdown<T> extends StatelessWidget {
  const CustomFieldDropdown({
    super.key,
    this.title,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final Widget? prefixIcon;
  final T? selected;
  final bool enabled;
  final String? title;
  final String? hintText;
  final ValueChanged<T?> onChanged;
  final List<DropdownMenuItem<T>>? items;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w700,
              color: AppColors.typographyHeading,
            ),
          ),
          SizedBox(height: AppSize.getHeight(6)),
        ],
        DropdownButtonFormField<T>(
          items: items,
          initialValue: selected,
          validator: validator,
          style: TextStyle(
            fontSize: AppSize.font(14),
            fontWeight: FontWeight.w600,
            color: AppColors.typographyHeading,
          ),
          onChanged: enabled ? onChanged : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            prefixIconConstraints: BoxConstraints(
              maxWidth: AppSize.getWidth(80),
              maxHeight: AppSize.getHeight(80),
            ),
            prefixIcon: prefixIcon,
            enabled: enabled,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w400,
              color: AppColors.typographySubtitle,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSize.getSize(12),
              horizontal: AppSize.getSize(16),
            ),
          ),
        ),
      ],
    );
  }
}

/// The searchable dropdown every feature uses ("F19: every dropdown is
/// searchable — use CustomFieldDropdown2").
///
/// Opens the picker as a modal bottom sheet, not an anchored menu — see the
/// 2026-09-23 core deltas on [popupProps] below for why.
class CustomFieldDropdown2<T> extends StatelessWidget {
  /// Creates a searchable dropdown field.
  const CustomFieldDropdown2({
    super.key,
    this.title,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.itemAsString,
    this.searchHint,
  });

  /// Leading icon shown inside the field itself (not the popup).
  final Widget? prefixIcon;

  /// The currently selected item, if any.
  final T? selected;

  /// Whether the field can be opened and changed.
  final bool enabled;

  /// The field's label, shown above the input.
  final String? title;

  /// Placeholder text shown when nothing is selected.
  final String? hintText;

  /// Called with the newly selected item.
  final ValueChanged<T?> onChanged;

  /// The full list of choices.
  final List<T> items;

  /// Validates the selected item.
  final FormFieldValidator<T>? validator;

  /// Renders an item as display text; also what the search box matches
  /// against.
  final String Function(T)? itemAsString;

  /// Placeholder inside the popup's search box.
  ///
  /// **Core delta, 2026-09-23.** The legacy widget turns the search box on and
  /// leaves it blank, which reads as a stray text field above a list rather
  /// than something to type in. Optional and defaulted, so every existing
  /// caller behaves exactly as before.
  final String? searchHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: AppSize.getHeight(6)),
        ],
        DropdownSearch<T>(
          enabled: enabled,
          items: (i, c) => items,
          selectedItem: selected,
          onSelected: onChanged,
          validator: validator,
          compareFn: (a, b) => a == b,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              prefixIconConstraints: BoxConstraints(
                maxWidth: AppSize.getWidth(80),
                maxHeight: AppSize.getHeight(80),
              ),
              hintText: hintText,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.inputPlaceholder),
              contentPadding: AppSize.padding(
                horizontal: AppSpacing.controlPaddingH,
                vertical: AppSpacing.controlPaddingV,
              ),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.iconGray,
              ),
            ),
          ),
          // **Core delta, 2026-09-23 — a sheet, not an anchored menu.**
          // `PopupProps.menu` computes its position **once**, from the field's
          // render box, and never moves: it is a `PopupRoute` with a fixed
          // rect. Tapping the search box then raises the keyboard *over* the
          // lower half of that rect, and since these fields sit in the middle
          // of a form the menu opens downward into exactly the space the
          // keyboard takes. Taps on a covered row land on the keyboard, so the
          // picker appeared to ignore them — it neither closed nor selected.
          //
          // A modal sheet is laid out against the live viewport instead, so it
          // sits above the keyboard and resizes with it. It is also the right
          // shape for this content: the catalogue is long, and a sheet gets
          // the full width and a real scroll area rather than a strip pinned
          // under a form field.
          popupProps: PopupProps<T>.modalBottomSheet(
            showSearchBox: true,
            // Deliberately minimal. The package already lifts the sheet above
            // the keyboard with a bottom margin of `viewInsets.bottom`, and a
            // height cap of our own fights that margin: cap and inset both
            // shrink the box, and the rows can end up drawn outside what the
            // sheet actually clips — visible, but not hit-testable, which is
            // exactly "the tap does nothing". `isScrollControlled` lets the
            // sheet use the height it needs; everything else is the package's
            // own default, so there is one less thing of ours in the layout.
            modalBottomSheetProps: const ModalBottomSheetProps(
              isScrollControlled: true,
            ),
            // **Core delta, 2026-09-23 — the search box did not search.**
            // `dropdown_search` only filters in memory when `cacheItems` is
            // on; without it every keystroke re-calls the `items` callback and
            // expects *that* to do the filtering, server-side style. This
            // widget's callback ignores the filter and returns the whole list,
            // so typing narrowed nothing. The list here is already in memory —
            // `GET car-brands` is unpaginated and fetched once — so caching it
            // is both correct and what makes `itemAsString` the thing matched
            // against.
            cacheItems: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                isDense: true,
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.iconGray),
                hintStyle: TextStyle(
                  fontSize: AppSize.font(14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.typographySubtitle,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSize.getSize(10),
                  horizontal: AppSize.getSize(12),
                ),
              ),
            ),
            itemBuilder:
                (BuildContext context, T item, bool isDisabled, bool isSelected) =>
                    Padding(
                      padding: AppSize.padding(horizontal: 14, vertical: 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              itemAsString?.call(item) ?? item.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: AppSize.getSize(18),
                              color: AppColors.brand600,
                            ),
                        ],
                      ),
                    ),
          ),
          dropdownBuilder: (context, selectedItem) {
            return Text(
              selectedItem != null
                  ? (itemAsString?.call(selectedItem) ??
                        selectedItem.toString())
                  : '',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          },
          itemAsString: itemAsString,
        ),
      ],
    );
  }
}
