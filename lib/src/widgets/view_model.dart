import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef BuildViewWithModel<M extends Model<M>> = Widget Function(
  M model,
  bool showProgress,
  double? progress,
  Widget? error,
);

class ViewModel<M extends Model<M>, BES extends CrudBloc<M>>
    extends StatefulWidget {
  const ViewModel({
    Key? key,
    required this.id,
    required this.buildWithModel,
    this.buildLoading,
    this.ignoreUnsaved = true,
    this.initalValue,
    this.autoUpdate = false,
  }) : super(key: key);

  final Pk<M> id;
  final BuildViewWithModel<M> buildWithModel;
  final LoadingBuildFunction<M>? buildLoading;
  final bool ignoreUnsaved;
  final M? initalValue;
  final bool autoUpdate;

  @override
  State<ViewModel> createState() => _ViewModelState<M, BES>();
}

class _ViewModelState<M extends Model<M>, BES extends CrudBloc<M>>
    extends State<ViewModel<M, BES>> {
  late final GetOne<M> queryEvent = GetOne<M>(id: widget.id);
  late final BES bloc = BlocProvider.of<BES>(context);

  Widget onLoading(final double? progress) {
    if (widget.initalValue != null) {
      return widget.buildWithModel(
        widget.initalValue!,
        false,
        null,
        null,
      );
    }
    if (widget.buildLoading != null) {
      return widget.buildLoading!(progress);
    }
    return Center(child: CircularProgressIndicator(value: progress));
  }

  Widget buildWidget(OneResultState<M> state) {
    Widget? error;
    if (state.error != null) {
      error = BackendErrorStateWidget(
        info: state.error!,
        onReload: () => BlocProvider.of<BES>(context).add(queryEvent),
      );
    }
    if (state.hasData) {
      return widget.buildWithModel(
        state.model!,
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
    if (widget.initalValue == null) {
      bloc.queriesAdd(queryEvent);
    }
    if (widget.autoUpdate) {
      bloc.addListener(queryEvent);
    }
  }

  @override
  void dispose() {
    if (widget.autoUpdate) {
      bloc.removeListener(queryEvent);
    }
    bloc.queriesRemove(queryEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyViewBlocBuilder<M, BES>(
      event: queryEvent,
      onLoading: onLoading,
      buildWidget: buildWidget,
      ignoreUnsaved: widget.ignoreUnsaved,
    );
  }
}
