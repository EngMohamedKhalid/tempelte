import 'package:easy_localization/easy_localization.dart';

enum ProviderTypeEnum { freelancer, business }

extension ProviderTypeExtension on ProviderTypeEnum {
  String get title {
    switch (this) {
      case ProviderTypeEnum.freelancer:
        return "sign_up.freelancer".tr();
      case ProviderTypeEnum.business:
        return "sign_up.business".tr();
    }
  }
}

ProviderTypeEnum? getProviderTypeEnum(String? key) {
  switch (key) {
    case "freelancer":
      return ProviderTypeEnum.freelancer;
    case "business":
      return ProviderTypeEnum.business;
    default:
      return null;
  }
}
