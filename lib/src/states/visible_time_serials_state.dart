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

import 'package:openvisu_repository/openvisu_repository.dart';

class VisibleTimeSerialsState {
  final List<Pk<TimeSerial>> availableTimeSerials;
  final List<Pk<TimeSerial>> visibleTimeSerials;

  VisibleTimeSerialsState.empty()
      : availableTimeSerials = [],
        visibleTimeSerials = [];

  VisibleTimeSerialsState({
    required this.availableTimeSerials,
    required this.visibleTimeSerials,
  });

  VisibleTimeSerialsState copyWith({
    final List<Pk<TimeSerial>>? availableTimeSerials,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
  }) {
    final List<Pk<TimeSerial>> newAvailableTimeSerials = [
      ...(availableTimeSerials ?? this.availableTimeSerials)
    ];

    final List<Pk<TimeSerial>> newVisibleTimeSerials = [
      ...(visibleTimeSerials ?? this.visibleTimeSerials)
    ];

    // cleanup visible timeSerials if no longer available
    if (availableTimeSerials != null) {
      for (final Pk<TimeSerial> id in this.visibleTimeSerials) {
        if (!newAvailableTimeSerials.contains(id) &&
            newVisibleTimeSerials.contains(id)) {
          newVisibleTimeSerials.remove(id);
        }
      }
    }

    // add newly available timeSerials to be visible
    if (availableTimeSerials != null && visibleTimeSerials == null) {
      for (final Pk<TimeSerial> id in availableTimeSerials) {
        if (!this.availableTimeSerials.contains(id) &&
            !newVisibleTimeSerials.contains(id)) {
          newVisibleTimeSerials.add(id);
        }
      }
    }

    return VisibleTimeSerialsState(
      availableTimeSerials: newAvailableTimeSerials,
      visibleTimeSerials: newVisibleTimeSerials,
    );
  }

  bool isTimeSerialAvailable(final Pk<TimeSerial> id) {
    return availableTimeSerials.contains(id);
  }

  bool isTimeSerialVisible(final Pk<TimeSerial> id) {
    return visibleTimeSerials.contains(id);
  }
}
