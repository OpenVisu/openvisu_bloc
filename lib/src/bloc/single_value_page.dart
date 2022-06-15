import 'package:bloc/bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:logging/logging.dart';

class SingleValuePageBloc extends CrudBloc<SingleValuePage> {
  static final log = Logger('bloc/SingleValuePageBloc');

  final CrudRepository<SingleValuePage> repository;
  final NodeBloc nodeBloc;
  SingleValuePageBloc({
    required this.repository,
    required this.nodeBloc,
    required super.authenticationBloc,
  });

  @override
  CrudRepository<SingleValuePage> get crudRepository {
    return repository;
  }

  @override
  void onTransition(
    Transition<CrudEvent<SingleValuePage>, CrudState<SingleValuePage>>
        transition,
  ) {
    if (transition.event is GetOne<SingleValuePage> &&
        transition.nextState is OneResultState<SingleValuePage>) {
      final OneResultState<SingleValuePage> s =
          (transition.nextState as OneResultState<SingleValuePage>);
      SingleValuePage svp = s.model!;
      if (svp.node != null && s.error == null && !s.isLoading) {
        // if singleValuePage was loaded with a node model notify the NodeBloc
        nodeBloc.set(model: svp.node!);
      }
    }

    super.onTransition(transition);
  }
}
