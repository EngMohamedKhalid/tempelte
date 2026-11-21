import '../../network/local/cache/cache_helper.dart';
import '../../network/local/cache/cache_keys.dart';

class ForceLangModel {
  String? ar;
  String? en;
  String? value;

  ForceLangModel({this.ar, this.en, this.value});

  ForceLangModel.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
    value = CacheHelper.get(CacheKeys.lang) == CacheKeys.langAr ? ar : en;
  }
}
