import 'package:openvisu_repository/openvisu_repository.dart';

import 'crud.dart';

class NodeBloc extends CrudBloc<Node> {
  NodeBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Node> repository;

  @override
  CrudRepository<Node> get crudRepository {
    return repository;
  }
}
