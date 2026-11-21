/// How often the screen on screen re-reads its data (F23).
///
/// The owner's decision: every live screen, for every role, every 3 seconds —
/// "the data from the backend could be changed". One value, here, so changing
/// it is one line. The poller backs off from it while requests fail.
abstract final class AppPolling {
  static const Duration interval = Duration(seconds: 3);
}
