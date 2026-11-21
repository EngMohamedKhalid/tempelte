import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/live_poll/live_poll_cubit.dart';
import '../controllers/tab_activation/tab_activation_cubit.dart';

/// Keeps a data screen's data fresh, silently (F23).
///
/// Wraps the screen's body and does two things with [onRefresh] — usually the
/// screen cubit's `refresh`:
/// - **polls** it while the screen is the one on screen, every 3 s
///   ([LivePollCubit]);
/// - when the screen is a bottom-nav tab, calls it each time the shell shows
///   the tab **again** (a `BlocListener` does not fire for the initial state,
///   so the first open is not fetched twice).
///
/// "On screen" is checked when each tick fires: the screen's route must be
/// the top one — a pushed detail or an open dialog is a route above it — and,
/// in a shell, its tab must be the one shown. Both are looked up in `build`
/// and captured by the check; it holds no `BuildContext`.
class LiveScreen extends StatelessWidget {
  const LiveScreen({required this.onRefresh, required this.child, super.key});

  final Future<bool> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TabActivationCubit? tab =
        context.findAncestorWidgetOfExactType<BlocProvider<TabActivationCubit>>() ==
            null
        ? null
        : BlocProvider.of<TabActivationCubit>(context, listen: false);

    // The route is looked up here, in build — never inside `create`, where a
    // dependency would be registered in a callback that never runs again.
    final ModalRoute<Object?>? route = ModalRoute.of(context);

    final Widget body = tab == null
        ? child
        : BlocListener<TabActivationCubit, int>(
            bloc: tab,
            listener: (_, _) => onRefresh(),
            child: child,
          );

    return BlocProvider<LivePollCubit>(
      lazy: false,
      create: (_) => LivePollCubit(
        onTick: onRefresh,
        isVisible: () =>
            (route?.isCurrent ?? true) && (tab == null || tab.isShown),
      ),
      child: body,
    );
  }
}
