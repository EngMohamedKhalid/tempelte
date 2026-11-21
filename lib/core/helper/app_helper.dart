import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/features/user/controllers/user_cubit.dart';
import '../shared/features/user/models/user_model.dart';
import '../network/local/cache/cache_helper.dart';
import '../network/remote/apis/dio_helper.dart';
import 'app_locals.dart';
import 'app_navigator.dart';
import 'app_toast.dart';

class AppHelper {

  static Locale get locale {
    return AppLocales.supportedLocales[AppLocales.currentLang ?? 0];
  }
  static UserModel? get authUser {
    return UserCubit.get(AppNavigator.context).user;
  }

  /// CLOSE KEYBOARD
  static Future closeKeyboard() async {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// LUNCH MAP
  static void lunchMap(String lat, String long) async {
    String url = 'https://www.google.com/maps?q=$lat,$long';
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  /// LUNCH URLS
  static Future<void> lunchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  /// COPY TEXT
  static Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// PICK FILE FROM DEVICE
  ///
  /// file_picker 12 split single and multiple selection into two calls, so
  /// [allowMultiple] now chooses between them rather than being passed through.
  static Future<List<PlatformFile>> pickFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final FileType type = allowedExtensions != null
        ? FileType.custom
        : FileType.any;

    if (allowMultiple) {
      return FilePicker.pickFiles(
        allowedExtensions: allowedExtensions,
        type: type,
      );
    }

    final PlatformFile? file = await FilePicker.pickFile(
      allowedExtensions: allowedExtensions,
      type: type,
    );
    return file == null ? <PlatformFile>[] : <PlatformFile>[file];
  }

  /// HANDLE FILE BEFORE SEND TO APIS
  static Future<MultipartFile> prepareFileForUpload(String path) async {
    String? mimeType = lookupMimeType(path);
    MediaType? mediaType;
    if (mimeType != null) {
      List<String> types = mimeType.split('/');
      if (types.length == 2) mediaType = MediaType(types[0], types[1]);
    }
    var file = File(path);
    return MultipartFile.fromStream(
      () => file.openRead(),
      await file.length(),
      filename: file.path.split('/').last,
      contentType: mediaType ?? MediaType('application', 'octet-stream'),
    );
  }

  /// DOWNLOAD FILE AND OPEN ON DEVICE
  static Future<void> downloadAndOpenFile(
    String attachment, {
    bool serve = false,
  }) async {
    try {
      AppNavigator.push(
        const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${attachment.split('/').last}';
      final file = File(filePath);
      final api = serve ? 'files/download?FilePath=$attachment' : attachment;
      await DioHelper.download(url: api, savePath: filePath);
      await OpenFile.open(file.path);
      AppNavigator.pop();
    } catch (e) {
      AppNavigator.pop();
      AppToast.error('Error: $e');
    }
  }

  /// TIME FORMAT
  ///
  /// Neither the locale nor the timestamp is trusted: the legacy reads `lang`
  /// as a non-null String and parses with `DateTime.parse`, so a cleared cache
  /// or a malformed timestamp takes down whatever is rendering the time —
  /// which, in a chat bubble, is the whole thread.
  static String timeFormat(String? time, String format) {
    if (time == null) return '';
    final String lang =
        CacheHelper.get('lang') as String? ??
        AppLocales.supportedLocalesCodes[AppLocales.currentLang ?? 0];
    final DateTime? parsedTime = DateTime.tryParse(time);
    if (parsedTime == null) return '';
    return DateFormat(format, lang).format(parsedTime.toLocal());
  }

  /// How long ago [iso] (a server UTC stamp) was, against [now] (the clock,
  /// by default). Null when the stamp is missing or unreadable.
  static Duration? since(String? iso, {DateTime? now}) {
    final DateTime? at = iso == null ? null : DateTime.tryParse(iso);
    if (at == null) return null;
    return (now ?? DateTime.now()).toUtc().difference(at.toUtc());
  }

  /// A duration as staff and customers read it: "64 d 17 h" from a day up,
  /// "2 h 14 m", or "7 min" under an hour. A device clock ahead of the server reads as 0, never negative.
  static String elapsed(Duration d) {
    final Duration safe = d.isNegative ? Duration.zero : d;
    if (safe.inDays > 0) {
      return 'duration.days_hours'.tr(namedArgs: <String, String>{
        'd': '${safe.inDays}',
        'h': '${safe.inHours.remainder(24)}',
      });
    }
    final int h = safe.inHours;
    final String m = safe.inMinutes.remainder(60).toString();
    if (h > 0) {
      return 'duration.hours_minutes'.tr(namedArgs: <String, String>{'h': '$h', 'm': m});
    }
    return 'duration.minutes'.tr(namedArgs: <String, String>{'m': m});
  }

  /// The greeting for the hour: morning 05–11, afternoon 12–16, evening
  /// otherwise. A translation key.
  static String greetingKey(DateTime now) {
    if (now.hour >= 5 && now.hour < 12) return 'greeting.morning';
    if (now.hour >= 12 && now.hour < 17) return 'greeting.afternoon';
    return 'greeting.evening';
  }

  /// Opens the phone dialler on [phone]; a toast if the device cannot.
  static Future<void> callPhone(String phone) async {
    final bool opened = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!opened) AppToast.error('core.call_failed'.tr());
  }

  /// TIME AGO
  static String timeAgo(String? time) {
    if (time == null) return '';
    DateTime parsed = DateTime.parse(time).toLocal();
    DateTime now = DateTime.now();
    Duration difference = now.difference(parsed);
    if (difference.isNegative) {
      return '';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} w';
    } else if (difference.inDays < 365) {
      int months = (now.year - parsed.year) * 12 + (now.month - parsed.month);
      if (now.day < parsed.day) months -= 1;
      return '$months m';
    } else {
      int years = now.year - parsed.year;
      if (now.month < parsed.month ||
          (now.month == parsed.month && now.day < parsed.day)) {
        years -= 1;
      }
      return '$years y';
    }
  }

  static Future<DateTime?> pickDate({
    DateTime? min,
    DateTime? initial,
    DateTime? max,
  }) async {
    return await showDatePicker(
      context: AppNavigator.context,
      firstDate: min ?? DateTime.now(),
      initialDate: initial ?? min ?? DateTime.now(),
      lastDate: max ?? DateTime.parse("2222-12-31"),
    );
  }

  static Future<TimeOfDay?> pickTime({TimeOfDay? initial}) async {
    final ctx = AppNavigator.key.currentContext;
    if (ctx != null) {
      return await showTimePicker(
        context: ctx,
        initialTime: initial ?? TimeOfDay.now(),
      );
    }
    return null;
  }

  /// Fetch device information based on the platform (Android/iOS)
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = <String, String>{};
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo['platform'] = 'android';
        deviceInfo['manufacturer'] = androidInfo.manufacturer;
        deviceInfo['model'] = androidInfo.model;
        deviceInfo['osVersion'] = androidInfo.version.release;
        deviceInfo['deviceId'] = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo['platform'] = 'ios';
        deviceInfo['manufacturer'] = 'Apple';
        deviceInfo['model'] = iosInfo.utsname.machine;
        deviceInfo['osVersion'] = iosInfo.systemVersion;
        deviceInfo['deviceId'] = iosInfo.identifierForVendor ?? 'Unknown';
      }
    } catch (e) {
      debugPrint('Error fetching device info: $e');
    }
    return deviceInfo;
  }

  /// Get the app version dynamically using the package_info_plus plugin
  static Future<PackageInfo?> getPlatformInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> scanQrCode() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      AppNavigator.context,
      scanType: ScanType.qr,
      scanFormat: ScanFormat.ONLY_QR_CODE,
      barcodeAppBar: BarcodeAppBar(
        // Was a hardcoded English literal, on a screen a valet reads in
        // Arabic.
        appBarTitle: 'scan_qr.title'.tr(),
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: const Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );
    return res;
  }
}
