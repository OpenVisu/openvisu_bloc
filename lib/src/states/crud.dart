import 'package:equatable/equatable.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

abstract class CrudState<T extends Model<T>> extends Equatable {
  final Pk<T>? id;
  final List<Filter>? filters;
  final BackendErrorInformation? error;
  final bool isLoading;
  final double? progress;

  const CrudState({
    this.id,
    this.filters,
    this.error,
    required this.isLoading,
    this.progress,
  });

  bool get hasError => error != null;

  bool get hasData;

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        if (id != null) id!,
        if (filters != null) filters!,
        if (error != null) error!,
        isLoading,
        if (progress != null) progress!,
      ];
}

class InitLoadingState<T extends Model<T>> extends CrudState<T> {
  const InitLoadingState() : super(isLoading: true);

  @override
  final hasData = false;
}

class OneResultState<T extends Model<T>> extends CrudState<T> {
  final String? identifier;
  final T? model;
  final bool isSaved;

  const OneResultState({
    super.id,
    required super.isLoading,
    super.error,
    super.filters,
    super.progress,
    required this.isSaved,
    this.model,
    this.identifier,
  });

  @override
  bool get hasData => model != null;

  @override
  List<Object> get props => super.props
    ..addAll([
      isSaved,
      if (model != null) model!,
      if (identifier != null) identifier!,
    ]);
}

class MultipleResultState<T extends Model<T>> extends CrudState<T> {
  final List<T>? models;

  const MultipleResultState({
    required super.isLoading,
    this.models,
    super.error,
    super.filters,
    super.progress,
  });

  @override
  bool get hasData => models != null;

  @override
  List<Object> get props => super.props
    ..addAll([
      if (models != null) models!,
    ]);
}

class LoadedFileState<T extends Model<T>> extends CrudState<T> {
  // OneState?
  final String path;

  const LoadedFileState({required this.path, message, exception})
      : super(
          id: null,
          filters: null,
          error: null,
          isLoading: false,
        );

  @override
  // TODO: implement hasData
  bool get hasData => true;

  @override
  List<Object> get props => super.props
    ..addAll([
      path,
    ]);
}
