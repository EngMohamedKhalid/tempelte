import 'package:flutter_bloc/flutter_bloc.dart';

/// Drops emits that arrive after the cubit has closed, instead of throwing.
///
/// Every cubit here does work that outlives its screen: a request in flight, a
/// store lookup with a five-second timeout, a debounce timer. If the screen is
/// dismissed first the cubit is closed, and when that work finally returns,
/// `emit` throws `Bad state: Cannot emit new states after calling close` —
/// straight into the log as an unhandled exception, with the user already
/// somewhere else.
///
/// This was not theoretical: the force-update check does exactly that on a
/// cold start, and it took running the app to see it. Nothing is listening to
/// a closed cubit, so dropping the state is the correct outcome and crashing
/// is strictly worse.
mixin SafeEmit<S> on BlocBase<S> {
  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
