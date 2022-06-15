import 'package:openvisu_repository/openvisu_repository.dart';


import 'crud.dart';

class RoleBloc extends CrudBloc<Role> {
  RoleBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Role> repository;

  @override
  CrudRepository<Role> get crudRepository {
    return repository;
  }
}
