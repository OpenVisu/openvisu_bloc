import 'package:openvisu_repository/openvisu_repository.dart';
import 'crud.dart';

class UserBloc extends CrudBloc<User> {
  UserBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<User> repository;

  @override
  CrudRepository<User> get crudRepository {
    return repository;
  }
}
