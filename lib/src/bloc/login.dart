import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository authenticationRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc(
    this.authenticationRepository,
    this.authenticationBloc,
  ) : super(LoginInitial()) {
    on<LoginButtonPressed>(
      _handleLoginButtonPressed,
      transformer: sequential(),
    );
  }

  Future<void> _handleLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await authenticationRepository.authenticate(
        credentials: event.credentials,
        saveLogin: event.saveLogin,
      );
      authenticationBloc.add(LoggedIn());
      emit(LoginInitial());
    } catch (error) {
      String errorString = error.toString();
      if (errorString == 'HttpException: Failed to login: 400') {
        errorString =
            'Username or Password invalid for ${event.credentials.endpoint}.';
      } else {}
      emit(LoginFailure(error: errorString));
    }
  }
}
