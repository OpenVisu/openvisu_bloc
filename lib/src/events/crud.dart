import 'package:equatable/equatable.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

typedef OnSuccess<T> = Function(T t);

abstract class CrudEvent<T extends Model<T>> extends Equatable {
  const CrudEvent();

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [];
}

class Reset<T extends Model<T>> extends GetEvent<T> {
  @override
  bool matches(CrudState<T> state, {bool withLoading = false}) {
    throw UnimplementedError();
  }
}

/// GetEvents have a matches method to check it the current state is relevant to them
abstract class GetEvent<T extends Model<T>> extends CrudEvent<T> {
  final List<Filter>? filters;

  const GetEvent({this.filters});

  bool matches(CrudState<T> state, {bool withLoading = false});

  @override
  List<Object> get props => super.props
    ..addAll([
      if (filters != null) filters!,
    ]);
}

class GetOne<T extends Model<T>> extends GetEvent<T> {
  final Pk<T> id;
  final String? identifier;

  GetOne({
    this.identifier,
    required this.id,
  });

  @override
  bool matches(
    CrudState<T> state, {
    bool withLoading = false,
    bool ignoreUnsaved = true,
  }) {
    if (state is OneResultState<T>) {
      if (!state.isSaved && ignoreUnsaved) {
        return false;
      }
      if (state.isLoading && !withLoading) {
        return false;
      }
      if (identifier != null) {
        return state.identifier == identifier;
      }
      return state.id! == id;
    }
    return false;
  }

  @override
  List<Object> get props => super.props
    ..addAll([
      id,
      if (identifier != null) identifier!,
    ]);
}

class SetOne<T extends Model<T>> extends GetEvent<T> {
  final T model;

  SetOne({
    required this.model,
  });

  @override
  bool matches(CrudState<T> state, {bool withLoading = false}) {
    throw UnimplementedError();
  }

  @override
  List<Object> get props => super.props
    ..addAll([
      model,
    ]);
}

class GetMultiple<T extends Model<T>> extends GetEvent<T> {
  const GetMultiple({
    List<Filter>? filters,
  }) : super(filters: filters);

  @override
  bool matches(CrudState<T> state, {bool withLoading = false}) {
    if (state is MultipleResultState<T>) {
      if (state.isLoading && !withLoading) {
        return false;
      }
      return uolwq(state.filters, filters);
    }
    return false;
  }

  @override
  List<Object> get props => super.props
    ..addAll([
      if (filters != null) filters!,
    ]);
}

class Save<T extends Model<T>> extends CrudEvent<T> {
  final T model;
  final String? identifier;

  ///method that is called if the create or update was successfully performed
  final OnSuccess<T>? onSuccess;

  Save({
    required this.model,
    this.identifier,
    this.onSuccess,
  });

  @override
  List<Object> get props => super.props
    ..addAll([
      model,
      if (identifier != null) identifier!,
    ]);
}

class Delete<T extends Model<T>> extends CrudEvent<T> {
  final T model;

  ///method that is called if the delete was successfully performed
  final Function? onSuccess;

  const Delete({
    required this.model,
    this.onSuccess,
  });

  @override
  List<Object> get props => super.props
    ..addAll([
      model,
      if (onSuccess != null) onSuccess!,
    ]);
}

class Swap<T extends Model<T>> extends CrudEvent<T> {
  final T x;
  final T y;

  const Swap({
    required this.x,
    required this.y,
  });

  @override
  List<Object> get props => super.props..addAll([x, y]);
}

class Sort<T extends Model<T>> extends CrudEvent<T> {
  final List<T> models;

  const Sort({required this.models});

  @override
  List<Object> get props => super.props
    ..addAll([
      models,
    ]);
}

// TODO check if this can be removed?
class EditNode<T extends Model<T>> extends CrudEvent<T> {
  final int? nodeId;
  final dynamic newValue;

  const EditNode({required this.nodeId, required this.newValue});
  @override
  List<Object> get props => super.props
    ..addAll([
      if (nodeId != null) nodeId!,
      if (nodeId != newValue) newValue!,
    ]);
}
