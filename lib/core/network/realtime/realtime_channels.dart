/// The three private channels the backend broadcasts on.
///
/// Every one is private: a public channel is named rather than authorised, and
/// this application has no data that belongs on one.
class RealtimeChannels {
  RealtimeChannels._();

  /// A single booking. The customer it belongs to, or staff assigned to the
  /// car park it happened at. Carries `message.sent` and status changes.
  static String booking(int bookingId) => 'private-bookings.$bookingId';

  /// A car park's board activity. Staff assigned to that car park only.
  static String parking(int parkingId) => 'private-parkings.$parkingId';

  /// One user's own events — unread badges and anything addressed personally.
  static String user(int userId) => 'private-users.$userId';
}

/// Event names carried on those channels.
class RealtimeEvents {
  RealtimeEvents._();

  /// A chat message was sent.
  static const String messageSent = 'message.sent';

  /// A booking's status changed.
  static const String bookingUpdated = 'booking.updated';

  /// The board gained or changed a booking.
  static const String boardUpdated = 'board.updated';

  /// The unread message count changed.
  static const String unreadUpdated = 'unread.updated';
}
