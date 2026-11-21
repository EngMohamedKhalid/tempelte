import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter/material.dart';

import '../../network/local/cache/cache_helper.dart';
import '../../network/local/cache/cache_keys.dart';
import '../../validators/app_validators.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';

class CustomFieldPhone extends StatelessWidget {
  const CustomFieldPhone({
    super.key,
    this.title,
    this.hintText,
    this.helperText,
    this.selectedPhone,
    this.onPhoneChanged,
    this.selectedCountry,
    this.onCountryChanged,
    required this.controller,
  });

  final String? title;
  final String? hintText;
  final String? helperText;
  final Country? selectedCountry;
  final PhoneNumber? selectedPhone;
  final TextEditingController controller;
  final Function(Country)? onCountryChanged;
  final Function(PhoneNumber)? onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    final lang = CacheHelper.get(CacheKeys.lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w700,
              // Same label tone as CustomFieldText: navy-700 is illegible
              // on the dark navy-950 background.
              color: AppColors.typographyLabel,
            ),
          ),
          SizedBox(height: AppSize.getHeight(6)),
        ],
        Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            countries: [
              const Country(
                flag: '🇦🇪',
                code: 'AE',
                minLength: 9,
                maxLength: 9,
                dialCode: '971',
                name: 'United Arab Emirates',
                nameTranslations: {
                  'en': 'United Arab Emirates',
                  'ar': 'الإمارات العربية المتحدة',
                },
              ),
              const Country(
                flag: '🇸🇦',
                code: 'SA',
                minLength: 9,
                maxLength: 9,
                dialCode: '966',
                name: 'Saudi Arabia',
                nameTranslations: {
                  'en': 'Saudi Arabia',
                  'ar': 'المملكة العربية السعودية',
                },
              ),
              const Country(
                flag: '🇰🇼',
                code: 'KW',
                minLength: 8,
                maxLength: 8,
                dialCode: '965',
                name: 'Kuwait',
                nameTranslations: {'en': 'Kuwait', 'ar': 'الكويت'},
              ),
              const Country(
                flag: '🇶🇦',
                code: 'QA',
                minLength: 8,
                maxLength: 8,
                dialCode: '974',
                name: 'Qatar',
                nameTranslations: {'en': 'Qatar', 'ar': 'قطر'},
              ),
              const Country(
                flag: '🇧🇭',
                code: 'BH',
                minLength: 8,
                maxLength: 8,
                dialCode: '973',
                name: 'Bahrain',
                nameTranslations: {'en': 'Bahrain', 'ar': 'البحرين'},
              ),
              const Country(
                flag: '🇴🇲',
                code: 'OM',
                minLength: 8,
                maxLength: 8,
                dialCode: '968',
                name: 'Oman',
                nameTranslations: {'en': 'Oman', 'ar': 'عُمان'},
              ),
              const Country(
                flag: '🇯🇴',
                code: 'JO',
                minLength: 9,
                maxLength: 9,
                dialCode: '962',
                name: 'Jordan',
                nameTranslations: {'en': 'Jordan', 'ar': 'الأردن'},
              ),
              const Country(
                flag: '🇸🇾',
                code: 'SY',
                minLength: 9,
                maxLength: 9,
                dialCode: '963',
                name: 'Syria',
                nameTranslations: {'en': 'Syria', 'ar': 'سوريا'},
              ),
            ],
            // countries: [
            //   const Country(
            //     flag: '🇦🇪',
            //     code: 'AE',
            //     minLength: 9,
            //     maxLength: 9,
            //     dialCode: '971',
            //     name: 'United Arab Emirates',
            //     nameTranslations: {
            //       'en': 'United Arab Emirates',
            //       'ar': 'الإمارات العربية المتحدة',
            //     },
            //   ),
            //   const Country(
            //     flag: '🇸🇦',
            //     code: 'SA',
            //     minLength: 9,
            //     maxLength: 9,
            //     dialCode: '966',
            //     name: 'Saudi Arabia',
            //     nameTranslations: {
            //       'en': 'Saudi Arabia',
            //       'ar': 'المملكة العربية السعودية',
            //     },
            //   ),
            // ],
            languageCode: lang ?? 'ar',
            style: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w600,
            ),
            controller: controller,
            showCountryFlag: false,
            dropdownIcon: const Icon(Icons.keyboard_arrow_down),
            initialCountryCode: 'SA',
            onChanged: onPhoneChanged,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: hintText,
              helperText: helperText,
              contentPadding: EdgeInsets.symmetric(
                vertical: AppSize.getSize(12),
                horizontal: AppSize.getSize(16),
              ),
              suffixIconConstraints: BoxConstraints(
                minHeight: AppSize.getHeight(40),
                maxHeight: AppSize.getHeight(40),
              ),
              prefixIconConstraints: BoxConstraints(
                minHeight: AppSize.getHeight(40),
                maxHeight: AppSize.getHeight(40),
              ),
            ),
            dropdownTextStyle: TextStyle(
              fontSize: AppSize.font(14),
              fontWeight: FontWeight.w500,
            ),
            onCountryChanged: onCountryChanged,
            pickerDialogStyle: PickerDialogStyle(
              padding: EdgeInsets.symmetric(
                vertical: AppSize.getHeight(20),
                horizontal: AppSize.getWidth(16),
              ),
              countryNameStyle: TextStyle(
                fontSize: AppSize.font(14),
                fontWeight: FontWeight.w500,
              ),
              countryCodeStyle: TextStyle(
                fontSize: AppSize.font(14),
                fontWeight: FontWeight.w500,
              ),
              listTilePadding: EdgeInsets.zero,
              listTileDivider: const SizedBox(),
              searchFieldPadding: EdgeInsets.zero,
            ),
            dialogType: DialogType.showModalBottomSheet,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (phone) => AppValidators.phone(
              phone?.number,
              phone?.isValidNumber() ?? false,
            ),
            textInputAction: TextInputAction.next,
            dropdownDecoration: BoxDecoration(
              border: BorderDirectional(
                end: BorderSide(color: AppColors.inputOutline),
              ),
            ),
            flagsButtonMargin: EdgeInsets.only(
              left: lang == 'en' ? 10 : 10,
              right: lang == 'en' ? 10 : 10,
            ),
            // buildCounter: (context,
            //         {required currentLength,
            //         required isFocused,
            //         required maxLength}) =>
            //     SizedBox(),
            // validator: (v) => v.number?.exactLength(
            //   v?.number,
            //   selectedCountry?.maxLength ?? 9,
            // ),
          ),
        ),
      ],
    );
  }
}
