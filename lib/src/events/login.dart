import 'package:openvisu_repository/openvisu_repository.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final Credentials credentials;
  final bool saveLogin;

  const LoginButtonPressed({
    required this.credentials,
    required this.saveLogin,
  });

  @override
  String toString() => 'LoginButtonPressed { '
      'credentials: $credentials, '
      'saveLogin: $saveLogin '
      '}';
}
