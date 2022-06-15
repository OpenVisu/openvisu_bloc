import 'package:openvisu_repository/openvisu_repository.dart';

import 'crud.dart';

class TextPageBloc extends CrudBloc<TextPage> {
  TextPageBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<TextPage> repository;

  @override
  CrudRepository<TextPage> get crudRepository {
    return repository;
  }
}
