/// Compares dotted version strings.
///
/// The legacy force-update check does `split('.').map(int.parse)`, which
/// throws on any store version carrying a suffix — and this app's own version
/// is `5.5.7+11113`. A crash on launch is the worst possible outcome for a
/// gate whose only job is to decide whether to show a banner, so every step
/// here degrades instead of throwing.
abstract final class AppVersion {
  /// Splits a version into numeric segments, discarding any `+build` or
  /// `-prerelease` suffix and treating unparseable segments as zero.
  static List<int> segments(String version) {
    final String core = version.trim().split(RegExp(r'[+\-\s]')).first;
    if (core.isEmpty) return const <int>[0];
    return core
        .split('.')
        .map((String part) => int.tryParse(part.trim()) ?? 0)
        .toList();
  }

  /// Returns a negative number when [a] precedes [b], zero when they are
  /// equal, and a positive number when [a] is newer.
  ///
  /// Segments missing from either side count as zero, so `1.2` and `1.2.0`
  /// compare equal.
  static int compare(String a, String b) {
    final List<int> left = segments(a);
    final List<int> right = segments(b);
    final int length = left.length > right.length ? left.length : right.length;

    for (int i = 0; i < length; i++) {
      final int l = i < left.length ? left[i] : 0;
      final int r = i < right.length ? right[i] : 0;
      if (l != r) return l.compareTo(r);
    }
    return 0;
  }

  /// Whether [store] is newer than [installed].
  ///
  /// A blank or unreadable value on either side returns false: if we cannot
  /// tell, the user is let through rather than locked out of the app.
  static bool isOutdated({required String? installed, required String? store}) {
    if (installed == null || installed.trim().isEmpty) return false;
    if (store == null || store.trim().isEmpty) return false;
    return compare(store, installed) > 0;
  }
}
