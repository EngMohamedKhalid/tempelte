import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A poller that backs off instead of hammering.
///
/// It is the fallback for everything the websocket would carry, and it runs
/// until a websocket server is deployed. It backs off on failure, resets on
/// success, and stops entirely while the app is backgrounded.
///
/// The legacy app polls chat every 1 s, the driver board every 3 s and booking
/// detail every 5 s with a fixed `Timer.periodic`, foreground and background
/// alike.
class AdaptivePoller {
  /// Creates a poller that calls [onTick] every [interval], backing off up to
  /// [maxInterval] while [onTick] keeps failing.
  AdaptivePoller({
    required this.onTick,
    this.interval = const Duration(seconds: 15),
    this.maxInterval = const Duration(minutes: 2),
    this.name = 'poller',
  });

  /// Called on each tick. Return false to signal a failure and back off.
  final Future<bool> Function() onTick;

  /// The delay between ticks when everything is healthy.
  final Duration interval;

  /// The ceiling the backoff will not exceed.
  final Duration maxInterval;

  /// Label used in log lines.
  final String name;

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  int _failures = 0;
  bool _running = false;
  bool _paused = false;

  /// Whether the poller is scheduled.
  bool get isRunning => _running;

  /// The delay currently in effect, doubling per consecutive failure.
  Duration get currentInterval {
    if (_failures == 0) return interval;
    final int factor = math.min(1 << _failures, 32);
    final int millis = math.min(
      interval.inMilliseconds * factor,
      maxInterval.inMilliseconds,
    );
    return Duration(milliseconds: millis);
  }

  /// Starts polling and begins watching the app lifecycle.
  void start() {
    if (_running) return;
    _running = true;
    _lifecycle ??= AppLifecycleListener(onStateChange: _onLifecycleChange);
    _schedule();
  }

  /// Stops polling and releases the lifecycle listener.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  /// Suspends ticking without forgetting the backoff state.
  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Resumes ticking after a [pause].
  void resume() {
    if (!_paused) return;
    _paused = false;
    if (_running) _schedule();
  }

  /// Ticks immediately and restarts the schedule from that point.
  Future<void> tickNow() async {
    _timer?.cancel();
    await _tick();
  }

  void _onLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        pause();
    }
  }

  void _schedule() {
    _timer?.cancel();
    if (!_running || _paused) return;
    _timer = Timer(currentInterval, _tick);
  }

  Future<void> _tick() async {
    if (!_running || _paused) return;
    try {
      final bool ok = await onTick();
      _failures = ok ? 0 : _failures + 1;
    } catch (e) {
      _failures += 1;
      log('$name tick failed: $e', name: 'realtime');
    }
    _schedule();
  }
}
