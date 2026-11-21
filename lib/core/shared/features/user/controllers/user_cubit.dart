import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controllers/safe_emit.dart';
import 'package:flutter/material.dart';

import '../../../../../features/shared/auth/data/repo/auth_repo.dart';
import '../../../../../features/shared/auth/data/repo/auth_repo_impel.dart';
import '../../../../network/local/cache/cache_helper.dart';
import '../../../../network/local/cache/cache_keys.dart';
import '../models/user_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> with SafeEmit<UserState> {
  UserCubit({AuthRepo? repo})
    : _repo = repo ?? AuthRepoImpel(),
      super(UserInitial());

  final AuthRepo _repo;

  static UserCubit get(BuildContext ctx) => BlocProvider.of(ctx);

  UserModel? user;

  /// Adopts a user the caller already has, without going to the network.
  ///
  /// Sign-in returns the whole user alongside the token, so refreshing after it
  /// fetched `/me` a second time for bytes already in hand.
  void setUser(UserModel value) {
    user = value;
    emit(SuccessUser());
  }

  Future<void> getUser() async {
    if (CacheHelper.get('token') == null) return;
    emit(LoadingUser());
    final api = await _repo.getUser();
    api.fold(
      (l) async {
        await CacheHelper.remove(CacheKeys.token);
        user = null;
        emit(Error());
      },
      (r) {
        user = r;

        emit(SuccessUser());
      },
    );
  }

  /// Re-reads `/me` silently — when Profile is shown again and on each poll
  /// (F23).
  ///
  /// Not [getUser]: that one shows a loading state and **removes the token on
  /// any failure**, so a network blip on a timer would sign the user out. Here
  /// a failure changes nothing; a real 401 still signs out through
  /// `ErrorInterceptor`, as everywhere else.
  Future<bool> refreshUser() async {
    if (CacheHelper.get(CacheKeys.token) == null) return true;
    final api = await _repo.getUser();
    return api.fold((_) => false, (UserModel value) {
      user = value;
      emit(SuccessUser());
      return true;
    });
  }
}
