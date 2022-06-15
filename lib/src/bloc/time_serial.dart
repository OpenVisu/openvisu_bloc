import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class TimeSerialBloc extends CrudBloc<TimeSerial> {
  TimeSerialBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<TimeSerial> repository;

  @override
  CrudRepository<TimeSerial> get crudRepository {
    return repository;
  }
}
