import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;
  final List<CrudBloc> blocs = [];

  AuthenticationBloc(this.authenticationRepository)
      : super(AuthenticationUninitialized()) {
    on<AppStarted>(_appStarted);
    on<LoggedIn>(_loggedIn);
    on<DoLogOut>(_doLogOut, transformer: sequential());
  }

  _appStarted(AppStarted event, Emitter<AuthenticationState> emit) async {
    final bool hasToken = await authenticationRepository.hasToken();

    if (hasToken) {
      emit(AuthenticationAuthenticated());
    } else {
      emit(AuthenticationUnauthenticated());
    }
  }

  _loggedIn(LoggedIn event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationAuthenticated());
  }

  _doLogOut(DoLogOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    await authenticationRepository.doLogout();
    _resetBlocs();
    emit(AuthenticationUnauthenticated());
  }

  _resetBlocs() {
    for (CrudBloc crudBloc in blocs) {
      crudBloc.reset();
    }
  }

  registerBloc(final CrudBloc crudBloc) {
    blocs.add(crudBloc);
  }
}
