import 'dart:async';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:openvisu_bloc/src/helper/queries.dart';
import 'package:openvisu_bloc/src/helper/updater.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

abstract class CrudBloc<T extends Model<T>>
    extends Bloc<CrudEvent<T>, CrudState<T>> with Queries<T>, Updater<T> {
  static final log = Logger('bloc/CrudBloc');

  Future<void> slowDown() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  final AuthenticationBloc authenticationBloc;

  CrudBloc({required this.authenticationBloc}) : super(InitLoadingState<T>()) {
    queriesInit(this);
    updaterInit(this);

    authenticationBloc.registerBloc(this);

    super.on<Reset<T>>(_handleResetEvent, transformer: sequential());
    super.on<GetMultiple<T>>(
      _handleGetMultipleEvent,
      transformer: sequential(),
    );
    super.on<GetOne<T>>(_handleGetEvent, transformer: sequential());
    super.on<SetOne<T>>(_handleSetEvent, transformer: sequential());
    super.on<Sort<T>>(handleSortEvent, transformer: sequential());
    super.on<Swap<T>>(_handleSwapEvent, transformer: sequential());
    super.on<Save<T>>(_handleSaveEvent, transformer: sequential());
    super.on<Delete<T>>(_handleDeleteEvent, transformer: sequential());
    super.on<EditNode<T>>(
      (event, emit) async =>
          await crudRepository.editNode(event.nodeId, event.newValue),
    );
  }

  CrudRepository<T> get crudRepository;

  reset() {
    add(Reset<T>());
  }

  save({
    required final T model,
    final OnSuccess<T>? onSuccess,
  }) {
    add(Save<T>(model: model, onSuccess: onSuccess));
  }

  set({
    required final T model,
  }) {
    crudRepository.setItemCache(model);
    add(SetOne<T>(model: model));
  }

  void _handleResetEvent(Reset<T> _, Emitter<CrudState<T>> emit) async {
    queriesClear();
    crudRepository.cacheClear();
    emit(InitLoadingState<T>());
  }

  void _handleGetMultipleEvent(
      GetMultiple<T> event, Emitter<CrudState<T>> emit) async {
    final List<T>? models = crudRepository.getListCache(
      event.filters.toString(),
    );
    if (models != null) {
      emit(MultipleResultState<T>(
        models: models,
        filters: event.filters,
        isLoading: true,
      ));
      await slowDown();
    }
    try {
      final List<T> models = await crudRepository.all(event.filters);
      await slowDown();
      emit(MultipleResultState<T>(
        models: models,
        filters: event.filters,
        isLoading: false,
      ));
    } on BackendError catch (e) {
      emit(MultipleResultState<T>(
        error: e.info,
        filters: event.filters,
        isLoading: false,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  void _handleGetEvent(GetOne<T> event, Emitter<CrudState<T>> emit) async {
    // create a new model
    if (event.id.isNew && event.filters == null && event.identifier != null) {
      emit(OneResultState<T>(
        id: Pk<T>.newModel(),
        identifier: event.identifier,
        model: crudRepository.createDefault() as T,
        isSaved: false,
        isLoading: false,
      ));
      return;
    }

    // load the model with the given id
    // if there is a version of the model cached, return it and indicate that
    // it is still loading
    T? model = crudRepository.getItemCache(event.id);
    if (model != null) {
      emit(OneResultState<T>(
        model: model,
        id: event.id,
        isSaved: true,
        isLoading: true,
      ));
      await slowDown();
    }
    // load the model from the server and remove loading bar
    try {
      final T loadedModel = await crudRepository.get(event.id);
      emit(OneResultState<T>(
        model: loadedModel,
        id: event.id,
        isSaved: true,
        isLoading: false,
      ));
    } on BackendError catch (e) {
      emit(OneResultState<T>(
        id: event.id,
        isSaved: true,
        isLoading: false,
        error: e.info,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  void _handleSetEvent(SetOne<T> event, Emitter<CrudState<T>> emit) async {
    crudRepository.setItemCache(event.model);
    emit(OneResultState<T>(
      model: event.model,
      id: event.model.id,
      isSaved: true,
      isLoading: false,
    ));
  }

  void handleSortEvent(Sort<T> event, Emitter<CrudState<T>> emit) async {
    emit(MultipleResultState(models: event.models, isLoading: true));
    try {
      await crudRepository.sort(event.models.map((e) => e.id).toList());
      emit(MultipleResultState(models: event.models, isLoading: false));
    } on BackendError catch (e) {
      emit(MultipleResultState<T>(
        error: e.info,
        filters: null,
        models: event.models,
        isLoading: false,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  void _handleSaveEvent(Save<T> event, Emitter<CrudState<T>> emit) async {
    try {
      emit(OneResultState<T>(
        model: event.model,
        id: event.model.id,
        identifier: event.identifier,
        isLoading: true,
        isSaved: false,
      ));
      await slowDown();
      late final Model model;
      if (event.model.isNew) {
        model = await crudRepository.add(event.model);
      } else {
        model = await crudRepository.update(event.model);
      }
      if (event.onSuccess != null) await event.onSuccess!(model as T);
      emit(OneResultState<T>(
        model: model as T,
        id: event.model.id,
        identifier: event.identifier,
        isLoading: false,
        isSaved: true,
      ));
    } on BackendError catch (e) {
      emit(OneResultState<T>(
        model: event.model,
        id: event.model.id,
        identifier: event.model.isNew ? event.identifier : null,
        error: e.info,
        isLoading: false,
        isSaved: false,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  void _handleSwapEvent(Swap<T> event, Emitter<CrudState<T>> emit) async {
    try {
      await crudRepository.swap(event.x, event.y);
      emit(OneResultState<T>(
        model: event.x,
        id: event.x.id,
        filters: null,
        isLoading: false,
        isSaved: true,
      ));
      emit(OneResultState<T>(
        model: event.y,
        id: event.y.id,
        filters: null,
        isLoading: false,
        isSaved: true,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  void _handleDeleteEvent(Delete<T> event, Emitter<CrudState<T>> emit) async {
    await event.model.beforeDelete();
    try {
      await crudRepository.delete(event.model.id);
      queriesModelDeleted(event.model.id, emit);
      if (event.onSuccess != null) event.onSuccess!();
    } on BackendError catch (e) {
      emit(OneResultState<T>(
        model: event.model,
        id: event.model.id,
        error: e.info,
        isLoading: false,
        isSaved: false,
      ));
    } on SocketException catch (e) {
      addError(e, StackTrace.current);
    } on ForbiddenRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    } on UnauthorizedRequest catch (e) {
      addError(e, StackTrace.current);
      authenticationBloc.add(DoLogOut());
    }
  }

  @override
  void onTransition(
    Transition<CrudEvent<T>, CrudState<T>> transition,
  ) {
    if (transition.event is Save<T> &&
        transition.nextState is OneResultState<T>) {
      final OneResultState<T> s = transition.nextState as OneResultState<T>;
      if (s.error == null) {
        for (GetEvent<T> getEvent in queriesAll()) {
          if (getEvent is GetMultiple<T>) {
            // multiple filters might be affected, thus reload all of them
            add(getEvent);
          }
        }
      }
    }

    super.onTransition(transition);
  }
}
