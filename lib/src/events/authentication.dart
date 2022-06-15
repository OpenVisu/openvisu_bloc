abstract class AuthenticationEvent {
  AuthenticationEvent([List props = const []]);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {

  LoggedIn() : super();

  @override
  String toString() => 'LoggedIn';
}

class DoLogOut extends AuthenticationEvent {
  DoLogOut();

  @override
  String toString() => 'LoggedOut';
}
