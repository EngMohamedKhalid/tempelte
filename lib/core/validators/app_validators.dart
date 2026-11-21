import 'package:easy_localization/easy_localization.dart';

import '../helper/app_locals.dart';

class AppValidators {
  /// Whether the app is currently showing Arabic. Validators run outside the
  /// widget tree, so they read the locale from [AppLocales] rather than a
  /// [BuildContext].
  static bool get _isAr => AppLocales.currentLocale.languageCode == 'ar';

  /// MANUAL BOOKING PRICE VALIDATION
  ///
  /// Mirrors the API contract for `POST driver/bookings/{id}/price`: required,
  /// numeric, between 0 and 1000000, at most two decimals. `0` is valid - it
  /// is how staff make a booking free.
  static String? price(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return _isAr ? 'الرجاء إدخال السعر' : 'Please enter the price';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(input)) {
      return _isAr
          ? 'أدخل رقمًا صحيحًا بحد أقصى خانتين عشريتين'
          : 'Enter a valid number with at most 2 decimals';
    }
    final parsed = num.tryParse(input);
    if (parsed == null) {
      return _isAr ? 'أدخل رقمًا صحيحًا' : 'Enter a valid number';
    }
    if (parsed < 0 || parsed > 1000000) {
      return _isAr
          ? 'يجب أن يكون السعر بين 0 و 1000000'
          : 'Price must be between 0 and 1000000';
    }
    return null;
  }

  /// REQUIRED VALIDATION
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else {
      return null;
    }
  }

  /// REQUIRED LENGTH VALIDATION
  static String? minLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (value.length < length) {
      return 'validators.length.min'.tr(namedArgs: {'length': '$length'});
    } else {
      return null;
    }
  }

  /// STOCK REQUIRED LENGTH VALIDATION
  static String? stockMinLength(String? value) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'validators.stock_min_length'.tr();
    }
    return null;
  }

  /// MAXIMUM LENGTH VALIDATION
  static String? maxLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (value.length > length) {
      return 'validators.length.max'.tr(namedArgs: {'length': '$length'});
    } else {
      return null;
    }
  }

  /// REQUIRED EXACT LENGTH VALIDATION
  static String? exactLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (value.length != length) {
      return 'validators.length.exact'.tr(namedArgs: {'length': '$length'});
    } else {
      return null;
    }
  }

  /// EMAIL VALIDATION
  static String? email(String? email) {
    if (email == null || email.isEmpty) {
      return 'validators.email.required'.tr();
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'validators.email.pattern'.tr();
    } else {
      return null;
    }
  }

  /// PASSWORD VALIDATION
  /// The server's rule: at least 8 characters.
  ///
  /// The copied validator only checked for emptiness, so a five-character
  /// password passed the form and came back as a 422 from `auth/register`
  /// — an error the user reads after submitting, about a field they have
  /// already left. `validators.password.min_length` was translated in all four
  /// locales and never reachable.
  // Owner, 2026-11-19: four, not eight. The server enforced 8 at sign-up
  // when last checked (2026-09); the backend team is to lower it to match.
  static const int passwordMinLength = 4;

  static String? password(String? password) {
    if (password == null || password.isEmpty) {
      return 'validators.password.required'.tr();
    } else if (password.length < passwordMinLength) {
      return 'validators.password.min_length'.tr();
    } else {
      return null;
    }
  }

  /// OLD PASSWORD NOT THE SAME AS NEW PASSWORD
  static String? oldPasswordNotNew(String? oldPassword, String? newPassword) {
    if (oldPassword == null || oldPassword.isEmpty) {
      return 'validators.password.required'.tr();
    } else if (newPassword == null || newPassword.isEmpty) {
      return 'validators.password.required'.tr();
    } else if (oldPassword == newPassword) {
      return 'validators.password.old_new_same'.tr();
    } else {
      return null;
    }
  }

  /// PASSWORD IDENTICAL
  static String? passwordIdentical(String? value, String? other) {
    if (value == null || value.isEmpty) {
      return 'validators.password.required'.tr();
    } else if (value != other) {
      return 'validators.password.identical'.tr();
    } else {
      return null;
    }
  }

  /// PHONE NUMBER VALIDATION
  static String? phone(String? value, bool isValid) {
    if (value == null || value.isEmpty) {
      return 'validators.phone.required'.tr();
    } else if (!isValid) {
      return 'validators.phone.invalid'.tr();
    } else {
      return null;
    }
  }

  /// ONLY NUMBERS AND LENGTH
  static String? onlyNumbers(String? value, {int? length}) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'validators.numbers.only'.tr();
    } else if (length != null && value.length != length) {
      return 'validators.numbers.exact_length'.tr(
        namedArgs: {'length': '$length'},
      );
    } else {
      return null;
    }
  }

  /// NUMBER LESS THAN VALIDATION
  static String? numLessThan(String? value, int max) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'validators.numbers.only'.tr();
    } else {
      int? intValue = int.tryParse(value);
      if (intValue == null) {
        return 'validators.numbers.only'.tr();
      } else if (intValue >= max) {
        return 'validators.numbers.less_than'.tr(namedArgs: {'max': '$max'});
      } else {
        return null;
      }
    }
  }

  /// VALUE IN RANGE VALIDATION
  static String? numInRange(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'validators.numbers.only'.tr();
    } else {
      int? intValue = int.tryParse(value);
      if (intValue == null) {
        return 'validators.numbers.only'.tr();
      } else if (intValue < min || intValue > max) {
        return 'validators.numbers.range'.tr(
          namedArgs: {'min': '$min', 'max': '$max'},
        );
      } else {
        return null;
      }
    }
  }

  /// NUMBER GREATER THAN VALIDATION
  static String? numGreaterThan(String? value, int min) {
    if (value == null || value.isEmpty) {
      return 'validators.required'.tr();
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'validators.numbers.only'.tr();
    } else {
      int? intValue = int.tryParse(value);
      if (intValue == null) {
        return 'validators.numbers.only'.tr();
      } else if (intValue <= min) {
        return 'validators.numbers.greater_than'.tr(namedArgs: {'min': '$min'});
      } else {
        return null;
      }
    }
  }

  /// OTP VALIDATION
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'validators.OTP.required'.tr();
    } else if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'validators.OTP.length'.tr();
    } else {
      return null;
    }
  }
}
