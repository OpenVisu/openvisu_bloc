import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class MyViewBlocBuilder<M extends Model<M>, BES extends CrudBloc<M>>
    extends StatelessWidget {
  static final log = Logger('my_view_bloc_builder/MyViewBlocBuilder');

  const MyViewBlocBuilder({
    Key? key,
    required this.event,
    required this.onLoading,
    required this.buildWidget,
    this.ignoreUnsaved = true,
  }) : super(key: key);

  /// contains the initial query
  final GetOne<M> event;

  /// used to render the initial loading page before any data is available
  final LoadingBuildFunction<M> onLoading;

  /// build the view from the available state
  final BuildFunctionOne<M> buildWidget;

  /// ignore unsaved model states
  final bool ignoreUnsaved;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BES, CrudState<M>>(
      buildWhen: (CrudState<M> previousState, CrudState<M> state) {
        if (previousState == state) {
          return false;
        }
        return state is InitLoadingState<M> ||
            event.matches(
              state,
              withLoading: true,
              ignoreUnsaved: ignoreUnsaved,
            );
      },
      builder: (BuildContext context, CrudState<M> state) {
        if (event.matches(
          state,
          withLoading: true,
          ignoreUnsaved: ignoreUnsaved,
        )) {
          return buildWidget(state as OneResultState<M>);
        }
        if (state is InitLoadingState<M>) {
          return onLoading(state.progress);
        }
        return onLoading(null);
      },
    );
  }
}
