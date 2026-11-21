import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network/realtime/adaptive_poller.dart';
import '../../../network/realtime/app_polling.dart';
import '../safe_emit.dart';

/// Polls one screen's data while that screen is the one on screen (F23).
///
/// Owns an [AdaptivePoller]: it ticks every [interval] ([AppPolling.interval],
/// 3 s, by default), doubles the delay per consecutive failure up to two minutes,
/// and pauses while the app is backgrounded. Each tick asks [isVisible] first
/// — a covered screen or a hidden tab skips without a request. The state is
/// the number of ticks that ran.
class LivePollCubit extends Cubit<int> with SafeEmit<int> {
  LivePollCubit({
    required Future<bool> Function() onTick,
    required bool Function() isVisible,
    Duration? interval,
  }) : super(0) {
    _poller = AdaptivePoller(
      name: 'live-screen',
      interval: interval ?? AppPolling.interval,
      onTick: () async {
        if (!isVisible()) return true;
        final bool ok = await onTick();
        emit(state + 1);
        return ok;
      },
    )..start();
  }

  late final AdaptivePoller _poller;

  @override
  Future<void> close() {
    _poller.stop();
    return super.close();
  }
}
