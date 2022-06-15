import 'package:openvisu_repository/openvisu_repository.dart';

import 'crud.dart';

class IFrameBloc extends CrudBloc<IFrame> {
  IFrameBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<IFrame> repository;

  @override
  CrudRepository<IFrame> get crudRepository {
    return repository;
  }
}
