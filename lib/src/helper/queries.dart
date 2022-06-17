// Copyright (C) 2022 Robin Jespersen
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:bloc/bloc.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

abstract class Queries<T extends Model<T>> {
  // list of queries that are active somwhere in the ui
  final Map<GetEvent<T>, int> _queries = {};

  late CrudBloc<T> bloc;

  void queriesInit(CrudBloc<T> bloc) {
    this.bloc = bloc;
  }

  queriesClear() {
    _queries.removeWhere((key, value) => true);
  }

  bool queriesContains(final GetEvent<T> getEvent) {
    return _queries.containsKey(getEvent);
  }

  void queriesAdd(final GetEvent<T> getEvent) {
    if (queriesContains(getEvent)) {
      _queries[getEvent] = _queries[getEvent]! + 1;
    } else {
      bloc.add(getEvent);
      _queries[getEvent] = 1;
    }
  }

  void queriesRemove(final GetEvent<T> getEvent) {
    if (queriesContains(getEvent) && _queries[getEvent]! > 1) {
      _queries[getEvent] = _queries[getEvent]! - 1;
    } else {
      _queries.remove(getEvent);
    }
  }

  // if an item was deleted, remove all further getEvents to this item
  void _queriesRemoveAll(final GetEvent<T> getEvent) {
    _queries.remove(getEvent);
  }

  List<GetEvent<T>> queriesAll() {
    return _queries.keys.toList();
  }

  /// after an item was deleted this method make sure to update
  /// all running queries
  queriesModelDeleted(final Pk<T> id, Emitter<CrudState<T>> emit) {
    for (GetEvent<T> getEvent in queriesAll()) {
      if (getEvent is GetOne<T>) {
        if (getEvent.id == id) {
          emit(OneResultState(
            id: getEvent.id,
            error: YiiErrorInformation.wasDeleted(),
            isSaved: true,
            isLoading: false,
          ));
          // the item was deleted, thus all further queries would fail
          _queriesRemoveAll(getEvent);
        }
      }
      if (getEvent is GetMultiple<T>) {
        // multiple filters might be affected, thus reload all of them
        bloc.add(getEvent);
      }
    }
  }
}
