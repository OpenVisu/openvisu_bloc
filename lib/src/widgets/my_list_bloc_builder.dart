import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class MyListBlocBuilder<M extends Model<M>,
    BES extends Bloc<CrudEvent<M>, CrudState<M>>> extends StatelessWidget {
  static final log = Logger('my_list_bloc_builder/MyListBlocBuilder');

  const MyListBlocBuilder({
    Key? key,
    required this.event,
    required this.onLoading,
    required this.buildWidget,
  }) : super(key: key);

  /// contains the initial query
  final GetMultiple<M> event;

  /// used to render the initial loading page before any data is available
  final LoadingBuildFunction<M> onLoading;

  /// build the view from the available state
  final BuildFunctionMultiple<M> buildWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BES, CrudState<M>>(
      buildWhen: (CrudState<M> previousState, CrudState<M> state) {
        if (previousState == state) {
          return false;
        }
        return state is InitLoadingState<M> ||
            event.matches(state, withLoading: true);
      },
      builder: (BuildContext context, CrudState<M> state) {
        if (event.matches(state, withLoading: true)) {
          return buildWidget(state as MultipleResultState<M>);
        }
        if (state is InitLoadingState<M>) {
          return onLoading(state.progress);
        }
        return onLoading(null);
      },
    );
  }
}
