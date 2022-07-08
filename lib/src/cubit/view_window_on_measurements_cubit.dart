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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class ViewWindowOnMeasurementsCubit extends Cubit<MultipleMeasurementsState>
    implements ViewWindowOnMeasurementsControler {
  final Pk<ChartPage> chartPageId;
  final List<Pk<TimeSerial>> timeSerialIds;
  final MeasurementsRepository measurementsRepository;
  final TimeSeriesCache cache = TimeSeriesCache();
  final TimeSeriesLoader timeSeriesLoader = TimeSeriesLoader();

  /// part of the viewport (time) that needs to pass before the chart is updated
  /// by the time
  final updateRate = 0.1;

  ViewWindowOnMeasurementsCubit({
    required this.chartPageId,
    required this.timeSerialIds,
    required this.measurementsRepository,
    required Duration viewPortWidth,
  }) : super(MultipleMeasurementsState.init(viewPortWidth, timeSerialIds)) {
    panedOrZoomedTo(state.viewPortStart, state.viewPortEnd);
  }

  @override
  void zoom(double scale, double focus) {
    Duration newViewPortWidth = state.viewPortWidth * scale;
    if (newViewPortWidth < const Duration(minutes: 1)) {
      newViewPortWidth = const Duration(minutes: 1);
    }
    if (newViewPortWidth > const Duration(days: 90)) {
      newViewPortWidth = const Duration(days: 90);
    }

    final Duration delta = (state.viewPortWidth - newViewPortWidth);

    late final DateTime start;
    DateTime end = state.viewPortEnd.subtract(delta * (1 - focus));
    final now = DateTime.now();
    if (end.isAfter(now)) {
      end = now;
      start = now.subtract(newViewPortWidth);
    } else {
      start = state.viewPortStart.add(delta * focus);
    }

    panedOrZoomedTo(start, end);
  }

  /// move the viewport one step to the left
  @override
  void goLeft({required double percentage}) {
    late final DateTime newViewPortStart;
    newViewPortStart = state.viewPortStart.subtract(
      state.viewPortWidth * percentage,
    );
    panedOrZoomedTo(
      newViewPortStart,
      newViewPortStart.add(state.viewPortWidth),
    );
  }

  /// move the viewport one step to the right
  @override
  void goRight({required double percentage, Offset? panPosition}) {
    late final DateTime newViewPortStart;
    newViewPortStart = state.viewPortStart.add(
      state.viewPortWidth * percentage,
    );
    panedOrZoomedTo(
      newViewPortStart,
      newViewPortStart.add(state.viewPortWidth),
    );
  }

  /// move the viewport to a specific time area
  /// currently end-start must be constant
  /// extend later to allow for zooming
  @override
  void panedOrZoomedTo(DateTime start, DateTime stop) async {
    final now = DateTime.now();
    if (stop.isAfter(now)) {
      stop = now;
      start = now.subtract(state.viewPortWidth);
    }

    emit(state.copyWith(
      measurements: measurementsRepository.getMultipleCached(
        timeSerialIds,
        start,
        stop,
      ),
      viewPortStart: start,
      viewPortEnd: stop,
      loading: false,
    ));
  }
}
