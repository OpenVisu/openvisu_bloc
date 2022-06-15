import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class ProjectBloc extends CrudBloc<Project> {
  ProjectBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Project> repository;

  @override
  CrudRepository<Project> get crudRepository {
    return repository;
  }
}
