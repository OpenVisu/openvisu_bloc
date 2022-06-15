import 'package:openvisu_repository/openvisu_repository.dart';

import 'crud.dart';

class ServerBloc extends CrudBloc<Server> {
  ServerBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Server> repository;

  @override
  CrudRepository<Server> get crudRepository {
    return repository;
  }
}
