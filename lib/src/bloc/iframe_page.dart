import 'package:openvisu_repository/openvisu_repository.dart';


import 'crud.dart';

class IframePageBloc extends CrudBloc<IframePage> {
  IframePageBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<IframePage> repository;

  @override
  CrudRepository<IframePage> get crudRepository {
    return repository;
  }
}
