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

class MultipleMeasurementsState {
  final Map<Pk<TimeSerial>, List<TimeSeriesEntry<double?>>> measurements;
  late final DateTime viewPortStart;
  late final DateTime viewPortEnd;
  final bool loading;

  MultipleMeasurementsState.init(
    final Duration viewPortWidth,
    final List<Pk<TimeSerial>> timeSerialIds,
  )   : measurements = {},
        loading = true {
    viewPortEnd = DateTime.now();
    viewPortStart = viewPortEnd.subtract(viewPortWidth);
  }

  MultipleMeasurementsState({
    required this.measurements,
    required this.loading,
    required this.viewPortStart,
    required this.viewPortEnd,
  });

  MultipleMeasurementsState copyWith({
    final Map<Pk<TimeSerial>, List<TimeSeriesEntry<double?>>>? measurements,
    final DateTime? viewPortStart,
    final DateTime? viewPortEnd,
    final bool? loading,
  }) {
    return MultipleMeasurementsState(
      measurements: measurements ?? this.measurements,
      viewPortStart: viewPortStart ?? this.viewPortStart,
      viewPortEnd: viewPortEnd ?? this.viewPortEnd,
      loading: loading ?? this.loading,
    );
  }

  Duration get viewPortWidth => viewPortEnd.difference(viewPortStart);

  @override
  String toString() {
    return 'MultipleMeasurementsState(loading: $loading, measurements.length: ${measurements.length}), measurements[Pk<TimeSerial>(1)]!.length: ${measurements[Pk<TimeSerial>(1)]!.length}, from: $viewPortStart, to: $viewPortEnd';
  }
}
