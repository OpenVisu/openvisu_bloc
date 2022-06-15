import 'dart:async';
import 'dart:math';

import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:logging/logging.dart';

class HistoryChartCubit extends ChartCubit<HistoryChartState> {
  static final log = Logger('cubit/cubit/HistoryChartCubit');

  /// keep at most n times the view port to the left and right
  final maxCacheSize = 2;

  /// reload data if less or equal this amount of view port is cached
  final minCacheSize = 1;

  /// part of the viewport (time) that needs to pass before the chart is updated
  /// by the time
  final updateRate = 0.1;

  late DateTime cacheBorderLeft;
  late DateTime cacheBorderRight;

  HistoryChartCubit({
    required final Pk<ChartPage> chartPageId,
    required final List<TimeSerial> timeSerials,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
    required final bool playing,
    required Duration viewPortWidth,
    required DateTime initViewPortEnd, // helper var, must be the current time
    required final ChartType chartType,
  }) : super(
            chartPageId: chartPageId,
            chartType: chartType,
            initialState: HistoryChartState(
              data: {
                for (TimeSerial ts in timeSerials) ts.id: ts.measurements,
              },
              viewPortStart: initViewPortEnd.subtract(viewPortWidth),
              viewPortEnd: initViewPortEnd,
              timeSerials: timeSerials,
              playing: playing,
              loading: false,
              chartType: chartType,
              viewPortTop: timeSerials.isEmpty
                  ? 1
                  : timeSerials.map((e) => e.maxValue).reduce(max),
              viewPortBottom: timeSerials.isEmpty
                  ? 0
                  : timeSerials.map((e) => e.minValue).reduce(min),
              visibleTimeSerials: visibleTimeSerials,
            )) {
    _updateCache();
    if (playing) {
      Duration duration = viewPortWidth * updateRate;
      if (duration.inSeconds < 10) {
        duration = const Duration(seconds: 10);
      }
      if (duration.inMinutes > 5) {
        duration = const Duration(minutes: 5);
      }
      timer = Timer.periodic(duration, (_) => _moveToNow());
    }
  }

  /// starts the auto update
  @override
  void startPlay() {
    if (state.playing) {
      return;
    }
    Duration duration = state.viewPortWidth * updateRate;
    if (duration.inSeconds < 10) {
      duration = const Duration(seconds: 10);
    }
    if (duration.inMinutes > 5) {
      duration = const Duration(minutes: 5);
    }
    _moveToNow();
    timer = Timer.periodic(duration, (_) => _moveToNow());
    emit(state.copyWith(playing: true));
  }

  @override
  void update({
    final ChartType? chartType,
    final Duration? viewPortWidth,
  }) {
    emit(state.copyWith(
      chartType: chartType,
      viewPortStart: viewPortWidth != null
          ? state.viewPortEnd.subtract(viewPortWidth)
          : null,
      data: viewPortWidth != null
          ? {
              for (Pk<TimeSerial> pkts in state.data.keys)
                pkts: state.data[pkts]!
                    .where((tse) => !(tse.time.isBefore(state.viewPortStart) ||
                        tse.time.isAfter(state.viewPortEnd)))
                    .toList(),
            }
          : null,
    ));
    if (viewPortWidth != null) {
      _updateCache();
    }
  }

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

  /// stops the auto update
  @override
  void stopPlay() {
    if (!state.playing) {
      return;
    }
    timer.cancel();
    emit(state.copyWith(playing: false));
  }

  /// moves the viewport to the current time
  void _moveToNow() {
    final DateTime now = DateTime.now();
    panedOrZoomedTo(now.subtract(state.viewPortWidth), now);
  }

  /// move the viewport one step to the left
  void goLeft({required double percentage}) {
    if (state.playing) {
      stopPlay();
    }
    late final DateTime newViewPortStart;
    newViewPortStart = state.viewPortStart.subtract(
      state.viewPortWidth * percentage,
    );
    panedOrZoomedTo(
        newViewPortStart, newViewPortStart.add(state.viewPortWidth));
  }

  /// move the viewport one step to the right
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
  void panedOrZoomedTo(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isAfter(now)) {
      end = now;
      start = now.subtract(state.viewPortWidth);
    }

    bool needsRefillLeft = false;
    bool needsRefillRight = false;
    bool needsDifferentResolution = false;
    if (start.isBefore(state.viewPortStart)) {
      needsRefillLeft = _requireLoadLeft(start);
    }
    if (end.isAfter(state.viewPortEnd)) {
      needsRefillRight = _requireLoadRight(end);
    }
    if (end.difference(start) != state.viewPortWidth) {
      needsDifferentResolution = _requireLoadResolution(start, end);
    }

    final bool loading =
        needsRefillLeft || needsRefillRight || needsDifferentResolution;

    emit(state.copyWith(
      viewPortStart: start,
      viewPortEnd: end,
    ));

    if (loading) {
      _updateCache();
    }
  }

  /// load new data in the cache
  /// currently everything is replaced
  /// extend later to only load new data and discard old data
  _updateCache() async {
    if (state.loading) {
      return;
    }
    emit(state.copyWith(
      loading: true,
    ));

    final DateTime now = DateTime.now();
    cacheBorderLeft =
        state.viewPortStart.subtract(state.viewPortWidth * maxCacheSize);
    cacheBorderRight =
        state.viewPortEnd.add(state.viewPortWidth * maxCacheSize);
    if (cacheBorderRight.isAfter(now)) {
      cacheBorderRight = now;
    }

    final Map<Pk<TimeSerial>, List<TimeSeriesEntry>> data =
        await InfluxdbRepository.get(
      chartPageId,
      cacheBorderLeft,
      cacheBorderRight,
    );

    emit(state.copyWith(
      data: data,
      loading: false,
    ));
  }

  /// test if the cached data to the left is below the threshold
  bool _requireLoadLeft(final DateTime viewPortLeft) {
    return viewPortLeft.difference(cacheBorderLeft) <
        state.viewPortWidth * minCacheSize;
  }

  /// test if the cached data to the right is below the threshold
  bool _requireLoadRight(final DateTime viewPortRight) {
    if (cacheBorderRight.isAfter(
      DateTime.now().subtract(const Duration(seconds: 10)),
    )) {
      return false;
    }
    return cacheBorderRight.difference(viewPortRight) <
        state.viewPortWidth * minCacheSize;
  }

  bool _requireLoadResolution(
    final DateTime viewPortLeft,
    final DateTime viewPortRight,
  ) {
    int visibleMeasurements =
        state.getMeasurementsInWindow(viewPortLeft, viewPortRight);
    return visibleMeasurements < 50 || visibleMeasurements > 100;
  }
}
