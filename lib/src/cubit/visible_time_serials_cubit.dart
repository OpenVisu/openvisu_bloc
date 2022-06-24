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
import 'package:openvisu_bloc/src/states/visible_time_serials_state.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:collection/collection.dart';

Function dueq = const DeepCollectionEquality.unordered().equals;

class VisibleTimeSerialsCubit extends Cubit<VisibleTimeSerialsState> {
  VisibleTimeSerialsCubit() : super(VisibleTimeSerialsState.empty());

  void updateTimeSerials(final List<Pk<TimeSerial>> timeSerials) {
    // if new list is equal to old, do nothing
    if (dueq(timeSerials, state.availableTimeSerials)) {
      return;
    }
    emit(state.copyWith(availableTimeSerials: timeSerials));
  }

  void showTimeSerial(final Pk<TimeSerial> id) {
    if (state.isTimeSerialVisible(id)) {
      return;
    }
    if (!state.isTimeSerialAvailable(id)) {
      return;
    }
    emit(
      state.copyWith(
        visibleTimeSerials: [...state.visibleTimeSerials, id],
      ),
    );
  }

  void hideTimeSerial(final Pk<TimeSerial> id) {
    if (!state.isTimeSerialVisible(id)) {
      return;
    }
    if (!state.isTimeSerialAvailable(id)) {
      return;
    }
    emit(
      state.copyWith(
        visibleTimeSerials: [...state.visibleTimeSerials]..remove(id),
      ),
    );
  }
}
