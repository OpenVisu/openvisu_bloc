import 'dart:async';

import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:logging/logging.dart';

class LiveChartCubit extends ChartCubit<LiveChartState> {
  static final log = Logger('cubit/cubit/LiveChartCubit');

  LiveChartCubit({
    required final Pk<ChartPage> chartPageId,
    required final List<TimeSerial> timeSerials,
    required final bool playing,
    required final ChartType chartType,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
  }) : super(
          chartPageId: chartPageId,
          chartType: chartType,
          initialState: LiveChartState(
            values: _timeSeriesToMap2(timeSerials),
            timeSerials: timeSerials,
            visibleTimeSerials:
                visibleTimeSerials ?? timeSerials.map((e) => e.id).toList(),
            playing: playing,
          ),
        ) {
    if (playing) {
      timer = Timer.periodic(
        const Duration(seconds: 10),
        (Timer t) => _refresh(),
      );
    }
  }

  @override
  void startPlay() {
    if (state.playing) {
      return;
    }

    emit(state.copyWith(playing: true));

    _load(chartPageId);

    if (!timer.isActive) {
      timer = Timer.periodic(
        const Duration(seconds: 10),
        (Timer t) => _refresh(),
      );
    }
  }

  @override
  void stopPlay() {
    if (!state.playing) {
      return;
    }
    timer.cancel();
    emit(state.copyWith(playing: false));
  }

  void _refresh() {
    _load(chartPageId, forceReload: true);
  }

  static Map<Pk<TimeSerial>, TimeSeriesEntry> _timeSeriesToMap2(
    List<TimeSerial> timeSerials,
  ) {
    Map<Pk<TimeSerial>, List<TimeSeriesEntry>> tmp = {};
    for (TimeSerial ts in timeSerials) {
      tmp[ts.id] = ts.measurements;
    }
    return _timeSeriesToMap(tmp);
  }

  static Map<Pk<TimeSerial>, TimeSeriesEntry> _timeSeriesToMap(
    Map<Pk<TimeSerial>, List<TimeSeriesEntry>> tmp,
  ) {
    Map<Pk<TimeSerial>, TimeSeriesEntry> data = {};

    for (Pk<TimeSerial> timeSeriesId in tmp.keys) {
      if (tmp[timeSeriesId]!.isNotEmpty) {
        data[timeSeriesId] = tmp[timeSeriesId]!.last;
      }
    }
    return data;
  }

  _load(final Pk<ChartPage> chartPageId, {bool forceReload = false}) async {
    final Map<Pk<TimeSerial>, List<TimeSeriesEntry>> tmp =
        await InfluxdbRepository.get(chartPageId, null, null);

    emit(state.copyWith(values: _timeSeriesToMap(tmp)));
  }

  @override
  void update({ChartType? chartType}) {}
}
