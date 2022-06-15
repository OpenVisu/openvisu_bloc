import 'dart:async';

import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Node Cubit which the authenticated user object
class MeCubit extends Cubit<MeCubitState> {
  final UserRepository userRepository;

  /// Initiating the Cubit with the default user
  MeCubit({
    required final BuildContext context,
  })  : userRepository = RepositoryProvider.of<UserRepository>(context),
        super(
            MeCubitState(user: User.createDefault(), loading: true, error: ''));

  /// Update the own user
  Future<void> update(context, User user) async {
    emit(state.copyWith(user: user, loading: true));

    try {
      user = await userRepository.updateMe(user);
      emit(state.copyWith(user: user, loading: false, error: ''));
    } catch (e) {
      user = User.createDefault();
      emit(state.copyWith(user: user, loading: false, error: e.toString()));
    }
  }

  ///  Load me data
  Future<void> load() async {
    emit(state.copyWith(loading: true));

    try {
      emit(state.copyWith(
        user: await userRepository.getMe(),
        loading: false,
        error: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        user: User.createDefault(),
        loading: false,
        error: e.toString(),
      ));
    }
  }
}

class MeCubitState {
  final User user;
  final bool loading;
  final String error;

  MeCubitState({
    required this.user,
    required this.loading,
    required this.error,
  });

  MeCubitState copyWith({
    user,
    loading,
    error,
  }) =>
      MeCubitState(
        user: user ?? this.user,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}
