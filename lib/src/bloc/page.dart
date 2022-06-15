import 'package:bloc/bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class PageBloc extends CrudBloc<Page> {
  PageBloc({
    required this.repository,
    required super.authenticationBloc,
  });

  final CrudRepository<Page> repository;

  @override
  CrudRepository<Page> get crudRepository {
    return repository;
  }

  /// pages are only sorted in the context of a dashboard
  /// so to there is always a filter present
  @override
  void handleSortEvent(Sort<Page> event, Emitter<CrudState<Page>> emit) async {
    final List<Filter> filters = [
      Filter(
        key: 'dashboard_id',
        operator: FilterType.EQ,
        value: '${event.models.first.dashboardId}',
      )
    ];
    emit(MultipleResultState(
      models: event.models,
      isLoading: true,
      filters: filters,
    ));
    try {
      await crudRepository.sort(event.models.map((e) => e.id).toList());
      emit(MultipleResultState(
        models: event.models,
        isLoading: false,
        filters: filters,
      ));
    } on BackendError catch (e) {
      emit(MultipleResultState<Page>(
        error: e.info,
        filters: filters,
        models: event.models,
        isLoading: false,
      ));
    }
  }
}
