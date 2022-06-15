import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class ChartPageBloc extends CrudBloc<ChartPage> {
  ChartPageBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<ChartPage> repository;

  @override
  CrudRepository<ChartPage> get crudRepository {
    return repository;
  }
}
