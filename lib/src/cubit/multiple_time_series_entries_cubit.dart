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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class MultipleTimeSeriesEntriesCubit
    extends Cubit<Map<Pk<TimeSerial>, TimeSeriesEntry<double?>?>> {
  final TimeSeriesEntryRepository timeSeriesEntryRepository;
  final List<Pk<TimeSerial>> ids;

  late Timer timer;

  MultipleTimeSeriesEntriesCubit({
    required this.ids,
    required this.timeSeriesEntryRepository,
  }) : super({
          for (final Pk<TimeSerial> id in ids)
            id: timeSeriesEntryRepository.getLast(id),
        }) {
    timer = Timer.periodic(const Duration(seconds: 5), _update);
  }

  _update(Timer timer) {
    if (isClosed) return;

    Map<Pk<TimeSerial>, TimeSeriesEntry<double?>?> newMap = {
      for (final Pk<TimeSerial> id in ids)
        id: timeSeriesEntryRepository.getLast(id),
    };

    for (final Pk<TimeSerial> id in ids) {
      if (state[id] == null && newMap[id] != null) {
        emit(newMap);
        return;
      } else if (state[id] != null &&
          newMap[id] != null &&
          state[id]!.time.isBefore(newMap[id]!.time)) {
        emit(newMap);
        return;
      }
    }
  }

  @override
  close() {
    timer.cancel();
    return super.close();
  }
}
