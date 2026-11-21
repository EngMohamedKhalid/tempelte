import 'package:dartz/dartz.dart';

import '../../network/errors/failure.dart';

/// The rules every live screen's silent refresh follows (F23).
///
/// A poll lands every 3 s, so it must never get in the way of the person using
/// the screen:
/// - it has its **own** in-flight flag — it never takes a lock a user action
///   needs, so a filter, a scope switch or pull-to-refresh is never dropped;
/// - a user-started load or action calls [invalidateRefresh]; a refresh that
///   began before that **discards** its result instead of overwriting newer
///   data, or ending an action's busy state early;
/// - it never falls back to the cubit's loading path — no spinner, no error
///   page, no permission prompt — even on a list that is empty or never loaded;
/// - [blocked] is checked before the request **and again after it**, so an
///   action that starts while the request is out still wins.
mixin SilentRefresh {
  int _generation = 0;
  bool _refreshing = false;

  /// For a refresh made of several requests (the walk-in): compare before and
  /// after each await.
  int get refreshGeneration => _generation;

  /// A user-started load or action: any refresh already in flight is stale.
  void invalidateRefresh() => _generation++;

  /// Runs one silent refresh. Returns false only when the request failed, so
  /// the poller backs off; a skipped or discarded refresh is healthy (true).
  ///
  /// [force] supersedes a refresh already in flight (used after an action,
  /// whose reload must not lose to a poll that read the old data).
  Future<bool> silentRefresh<T>({
    required Future<Either<Failure, T>> Function() fetch,
    required void Function(T value) apply,
    bool Function()? blocked,
    bool force = false,
  }) async {
    if (force) {
      invalidateRefresh();
    } else if (_refreshing) {
      return true;
    }
    if (blocked?.call() ?? false) return true;

    final int generation = _generation;
    _refreshing = true;
    final Either<Failure, T> result = await fetch();
    if (generation == _generation) _refreshing = false;

    if (generation != _generation || (blocked?.call() ?? false)) return true;
    return result.fold((Failure _) => false, (T value) {
      apply(value);
      return true;
    });
  }

  /// Updates [current] in place from [fresh] by id, keeping its length and
  /// order — for a list read past its first page, which a page-1 re-read must
  /// not cut back.
  static void mergeById<T>(
    List<T> current,
    List<T> fresh,
    Object? Function(T item) idOf,
  ) {
    final Map<Object?, T> byId = <Object?, T>{
      for (final T item in fresh)
        if (idOf(item) != null) idOf(item): item,
    };
    for (int i = 0; i < current.length; i++) {
      final T? replacement = byId[idOf(current[i])];
      if (replacement != null) current[i] = replacement;
    }
  }
}
