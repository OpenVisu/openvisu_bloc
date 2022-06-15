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
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChartCubit<T extends ChartState<T>> extends Cubit<T> {
  final Pk<ChartPage> chartPageId;
  final ChartType chartType;
  Timer timer = Timer(Duration.zero, () {});

  ChartCubit({
    required this.chartPageId,
    required this.chartType,
    initialState,
  }) : super(initialState);

  static ChartCubit<ChartState> fromChartPage(
    final ChartPage chartPage, {
    final playing = true,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
  }) {
    if (chartPage.isLive()) {
      return LiveChartCubit(
        chartPageId: chartPage.id,
        timeSerials: chartPage.timeSerials,
        chartType: chartPage.chartType,
        playing: playing,
        visibleTimeSerials: visibleTimeSerials,
      );
    } else {
      return HistoryChartCubit(
        chartPageId: chartPage.id,
        timeSerials: chartPage.timeSerials,
        viewPortWidth: chartPage.interval,
        initViewPortEnd: DateTime.now(),
        chartType: chartPage.chartType,
        playing: playing,
        visibleTimeSerials: visibleTimeSerials,
      );
    }
  }

  void showTimeSerial(Pk<TimeSerial> id) {
    if (!state.isTimeSerialVisible(id)) {
      emit(
        state.copyWith(
          visibleTimeSerials: state.visibleTimeSerials..add(id),
        ),
      );
    }
  }

  void hideTimeSerial(Pk<TimeSerial> id) {
    if (state.isTimeSerialVisible(id)) {
      emit(
        state.copyWith(
          visibleTimeSerials: state.visibleTimeSerials..remove(id),
        ),
      );
    }
  }

  void stopPlay();
  void startPlay();

  void update({final ChartType? chartType});
}
