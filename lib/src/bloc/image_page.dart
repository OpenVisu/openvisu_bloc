import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class ImagePageBloc extends CrudBloc<ImagePage> {
  ImagePageBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<ImagePage> repository;

  @override
  CrudRepository<ImagePage> get crudRepository {
    return repository;
  }
}
