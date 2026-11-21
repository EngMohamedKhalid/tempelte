part of 'force_update_cubit.dart';

@immutable
sealed class ForceUpdateState {
  const ForceUpdateState();
}

final class ForceUpdateInitial extends ForceUpdateState {
  const ForceUpdateInitial();
}

final class ForceUpdateChecking extends ForceUpdateState {
  const ForceUpdateChecking();
}

/// The installed build is current, or we could not tell. Either way the user
/// carries on — a failed store lookup must never lock anyone out.
final class ForceUpdateNotRequired extends ForceUpdateState {
  const ForceUpdateNotRequired();
}

/// The store has a newer build. [storeVersion] is what it offers.
final class ForceUpdateRequired extends ForceUpdateState {
  const ForceUpdateRequired({
    required this.installedVersion,
    required this.storeVersion,
  });

  final String installedVersion;
  final String storeVersion;
}
