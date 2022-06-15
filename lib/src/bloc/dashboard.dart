import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class DashboardBloc extends CrudBloc<Dashboard> {
  DashboardBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Dashboard> repository;

  @override
  CrudRepository<Dashboard> get crudRepository {
    return repository;
  }
}
