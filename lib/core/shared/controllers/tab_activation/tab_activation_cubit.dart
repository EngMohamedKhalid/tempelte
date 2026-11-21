import 'package:flutter_bloc/flutter_bloc.dart';

import '../safe_emit.dart';

/// One bottom-nav tab, as its shell sees it (F23).
///
/// Owned by the shell's layout cubit, one per tab, provided above the tab's
/// screen. The state counts how often the tab was **shown again** (switched
/// back to, or re-tapped) — a change is the signal to re-read. [isShown] says
/// whether the tab is the one on screen; the screen's poller reads it each
/// tick, so a hidden tab in the `IndexedStack` makes no requests.
class TabActivationCubit extends Cubit<int> with SafeEmit<int> {
  TabActivationCubit({this.isShown = false}) : super(0);

  /// Whether this tab is the one on screen. Set by the shell.
  bool isShown;

  /// The tab was shown again.
  void activate() => emit(state + 1);
}
