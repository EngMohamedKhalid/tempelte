import 'dart:ui';

/// The six status tones. One tone colours the badge, the stat-tile dot and a
/// list row's edge, so a status looks the same everywhere it appears.
///
/// Never used alone: whatever is tinted by a tone also carries a label.
enum AppTone {
  amber(
    bg: Color(0xFFFFFBEB),
    fg: Color(0xFF92400E),
    ring: Color.fromRGBO(217, 119, 6, 0.25),
    dot: Color(0xFFF5B53F),
    solid: Color(0xFFB45309),
    darkFg: Color(0xFFFCD34D),
  ),
  red(
    bg: Color(0xFFFEF2F2),
    fg: Color(0xFFB91C1C),
    ring: Color.fromRGBO(220, 38, 38, 0.20),
    dot: Color(0xFFEF4444),
    solid: Color(0xFFDC2626),
    darkFg: Color(0xFFFCA5A5),
  ),
  navy(
    bg: Color(0xFFF1F4FA),
    fg: Color(0xFF0D2350),
    ring: Color.fromRGBO(30, 58, 112, 0.25),
    dot: Color(0xFF1E3A70),
    solid: Color(0xFF0D2350),
    darkFg: Color(0xFFC1D0E9),
  ),
  sky(
    bg: Color(0xFFF0F9FF),
    fg: Color(0xFF075985),
    ring: Color.fromRGBO(2, 132, 199, 0.20),
    dot: Color(0xFF0EA5E9),
    solid: Color(0xFF0369A1),
    darkFg: Color(0xFF7DD3FC),
  ),
  green(
    bg: Color(0xFFECFDF5),
    fg: Color(0xFF065F46),
    ring: Color.fromRGBO(5, 150, 105, 0.20),
    dot: Color(0xFF10B981),
    solid: Color(0xFF047857),
    darkFg: Color(0xFF6EE7B7),
  ),
  gray(
    bg: Color(0xFFF8FAFC),
    fg: Color(0xFF334155),
    ring: Color.fromRGBO(100, 116, 139, 0.20),
    dot: Color(0xFF7B93C4),
    solid: Color(0xFF475569),
    darkFg: Color(0xFFCBD5E1),
  );

  const AppTone({
    required this.bg,
    required this.fg,
    required this.ring,
    required this.dot,
    required this.solid,
    required this.darkFg,
  });

  /// Badge background.
  final Color bg;

  /// Badge text. Clears 4.5:1 on [bg].
  final Color fg;

  /// The 1 px inset ring around a badge.
  final Color ring;

  /// The small dot on a stat tile, and a row's edge.
  final Color dot;

  /// The tone's dark step as a solid fill (F26): tone buttons and icon chips
  /// carry white text and icons on it, at ≥ 4.5:1.
  final Color solid;

  /// The tone's text colour on its dark-theme tint ([bgOn] with `dark`).
  final Color darkFg;

  /// The navy-900 surface the dark tint is laid over — `AppColors`
  /// `backgroundSecondaryDark`, repeated here because `AppColors` imports
  /// this file.
  static const Color _darkSurface = Color(0xFF081838);

  /// The tint behind a tone's text: the web's badge background in light, the
  /// dot at 16 % over the dark surface in dark.
  Color bgOn({required bool dark}) => dark
      ? Color.alphaBlend(dot.withValues(alpha: 0.16), _darkSurface)
      : bg;

  /// The solid fill for the theme (F26): navy lifts to navy-600 on dark
  /// cards, where its own navy-800 would vanish; the rest keep [solid].
  Color solidOn({required bool dark}) =>
      dark && this == AppTone.navy ? const Color(0xFF1E3A70) : solid;

  /// The tone's text colour on [bgOn] for the same theme.
  Color fgOn({required bool dark}) => dark ? darkFg : fg;

  /// Booking status → tone. Customer and staff bookings share it.
  static const Map<String, AppTone> booking = <String, AppTone>{
    'pending': amber,
    'confirmed': navy,
    'parked': sky,
    'requested': sky,
    'accepted': green,
    'completed': green,
    'cancelled': red,
  };

  /// Visit request status → tone.
  static const Map<String, AppTone> visit = <String, AppTone>{
    'approved': green,
    'pending': amber,
    'rejected': red,
  };

  /// Subscription status → tone. Reserved: subscriptions are not built.
  static const Map<String, AppTone> subscription = <String, AppTone>{
    'active': green,
    'pending': amber,
    'cancelled': red,
  };

  /// QR card status → tone. Reserved: nothing in the app shows one yet.
  static const Map<String, AppTone> qrCard = <String, AppTone>{
    'active': green,
    'lost': red,
    'retired': gray,
  };

  /// The server's word, trimmed and lower-cased — the form every map is keyed by.
  static String normalise(String? status) => (status ?? '').trim().toLowerCase();

  /// Tone for a booking status; anything unrecognised is [gray].
  static AppTone forBooking(String? status) => booking[normalise(status)] ?? gray;

  /// Whether [status] is one of the seven verified booking statuses.
  static bool isKnownBooking(String? status) =>
      booking.containsKey(normalise(status));

  /// Tone for a visit status; anything unrecognised is [gray].
  static AppTone forVisit(String? status) => visit[normalise(status)] ?? gray;

  /// Tone for a subscription status; anything unrecognised is [gray].
  static AppTone forSubscription(String? status) =>
      subscription[normalise(status)] ?? gray;

  /// Tone for a QR card status; anything unrecognised is [gray].
  static AppTone forQrCard(String? status) => qrCard[normalise(status)] ?? gray;
}
