import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class LibraryEntryBloc extends CrudBloc<LibraryEntry> {
  LibraryEntryBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<LibraryEntry> repository;

  @override
  CrudRepository<LibraryEntry> get crudRepository {
    return repository;
  }
}
