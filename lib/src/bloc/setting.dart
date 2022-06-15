import 'package:openvisu_repository/openvisu_repository.dart';

import 'crud.dart';

class SettingBloc extends CrudBloc<Setting> {
  SettingBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Setting> repository;

  @override
  CrudRepository<Setting> get crudRepository {
    return repository;
  }
}
