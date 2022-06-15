import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef BuildViewWithModels<M extends Model<M>> = Widget Function(
  List<M> models,
  bool showProgress,
  double? progress,
  Widget? error,
);

class ViewModels<M extends Model<M>, BES extends CrudBloc<M>>
    extends StatefulWidget {
  const ViewModels({
    Key? key,
    required this.filters,
    required this.buildWithModels,
    this.buildLoading,
  }) : super(key: key);

  final List<Filter> filters;
  final BuildViewWithModels<M> buildWithModels;
  final LoadingBuildFunction<M>? buildLoading;

  @override
  State<ViewModels> createState() => _ViewModelsState<M, BES>();
}

class _ViewModelsState<M extends Model<M>, BES extends CrudBloc<M>>
    extends State<ViewModels<M, BES>> {
  late final GetMultiple<M> queryEvent =
      GetMultiple<M>(filters: widget.filters);
  late final BES blocProvider = BlocProvider.of<BES>(context);

  Widget onLoading(final double? progress) {
    if (widget.buildLoading != null) {
      return widget.buildLoading!(progress);
    }
    return Center(child: CircularProgressIndicator(value: progress));
  }

  Widget buildWidget(MultipleResultState<M> state) {
    Widget? error;
    if (state.error != null) {
      error = BackendErrorStateWidget(
        info: state.error!,
        onReload: () => blocProvider.add(queryEvent),
      );
    }
    if (state.hasData) {
      return widget.buildWithModels(
        state.models!,
        state.isLoading,
        state.progress,
        error,
      );
    }
    if (error != null) {
      return error;
    }
    return onLoading(null);
  }

  @override
  void initState() {
    super.initState();
    blocProvider.queriesAdd(queryEvent);
  }

  @override
  void dispose() {
    blocProvider.queriesRemove(queryEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyListBlocBuilder<M, BES>(
      event: queryEvent,
      onLoading: onLoading,
      buildWidget: buildWidget,
    );
  }
}
