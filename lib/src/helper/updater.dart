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

import 'dart:async';

import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

abstract class Updater<T extends Model<T>> {
  // list of queries that should be refreshed regulary
  final Map<GetEvent<T>, int> _queries = {};

  Timer timer = Timer(Duration.zero, () {});

  late CrudBloc<T> bloc;

  void updaerInit(CrudBloc<T> bloc) {
    this.bloc = bloc;
  }

  void addListener(final GetEvent<T> getEvent) {
    if (_queries.containsKey(getEvent)) {
      _queries[getEvent] = _queries[getEvent]! + 1;
    } else {
      _queries[getEvent] = 1;
      if (!timer.isActive) {
        timer =
            Timer.periodic(const Duration(seconds: 10), (Timer t) => _update());
      }
    }
  }

  void removeListener(final GetEvent<T> getEvent) {
    if (_queries.containsKey(getEvent) && _queries[getEvent]! > 1) {
      _queries[getEvent] = _queries[getEvent]! - 1;
    } else {
      _queries.remove(getEvent);
      if (_queries.isEmpty && timer.isActive) {
        timer.cancel();
      }
    }
  }

  void _update() {
    for (final GetEvent<T> getEvent in _queries.keys) {
      bloc.add(getEvent);
    }
    if (_queries.isEmpty) {
      timer.cancel();
    }
  }
}