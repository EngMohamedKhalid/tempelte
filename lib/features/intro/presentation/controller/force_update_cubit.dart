import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/controllers/safe_emit.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constant/app_constants.dart';
import '../../../../../core/helper/app_toast.dart';
import '../../data/models/app_version.dart';

part 'force_update_state.dart';

/// Decides whether the installed build is too old to use.
///
/// Three corrections to the legacy implementation, which lives in
/// `_MyAppState` and drives the decision with `setState`:
///
/// 1. It is a Cubit, so nothing about this is UI state.
/// 2. The version comparison cannot throw. The legacy one does
///    `split('.').map(int.parse)`, which blows up on any store version with a
///    suffix — and this app's own version string is `5.5.7+11113`.
/// 3. A failed or slow store lookup resolves to "not required" rather than
///    blocking the app. The gate exists to nudge users forward, not to strand
///    them when Apple or Google is unreachable.
class ForceUpdateCubit extends Cubit<ForceUpdateState> with SafeEmit<ForceUpdateState> {
  ForceUpdateCubit() : super(const ForceUpdateInitial());

  static ForceUpdateCubit get(BuildContext ctx) => BlocProvider.of(ctx);

  /// How long to wait on the store before giving up and letting the user in.
  static const Duration lookupTimeout = Duration(seconds: 5);

  /// Checks the store listing for a newer build.
  final Upgrader upgrader = Upgrader();

  Future<void> check() async {
    emit(const ForceUpdateChecking());
    try {
      await upgrader.initialize().timeout(lookupTimeout);

      final UpgraderVersionInfo? info = upgrader.state.versionInfo;
      final String? installed = info?.installedVersion?.toString();
      final String? store = info?.appStoreVersion?.toString();

      if (AppVersion.isOutdated(installed: installed, store: store)) {
        emit(
          ForceUpdateRequired(
            installedVersion: installed!,
            storeVersion: store!,
          ),
        );
        return;
      }
      emit(const ForceUpdateNotRequired());
    } catch (e) {
      // Unreachable store, no listing, a timeout — none of these are the
      // user's problem, so let them through.
      log('update check skipped: $e', name: 'force_update');
      emit(const ForceUpdateNotRequired());
    }
  }

  /// Opens the platform's store page.
  ///
  /// Deliberately not `Upgrader.sendUserToAppStore()`: that only works when
  /// the lookup in [check] succeeded, and it reports nothing when the store
  /// will not open, so `update.cannot_open_store` would never be seen. The URL
  /// is built from [AppConstants] instead, which is also the fix for the
  /// legacy popup hardcoding a bundle id this project no longer uses.
  Future<void> openStore() async {
    final Uri url = Uri.parse(AppConstants.storeUrl);
    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) AppToast.error('update.cannot_open_store'.tr());
  }
}
