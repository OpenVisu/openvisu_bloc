import 'package:fl_chart/fl_chart.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class HistoryChartState extends ChartState<HistoryChartState> {
  final DateTime dateTime = DateTime.now();
  final Map<Pk<TimeSerial>, List<TimeSeriesEntry>> data;

  /// contains all current measurements points
  /// limited part gets shown because of the viewPort Start / End
  final Map<Pk<TimeSerial>, List<FlSpot>> points;

  final bool loading;

  final DateTime viewPortStart;
  final DateTime viewPortEnd;
  final Duration viewPortWidth;

  final double viewPortHeight;
  final double viewPortTop;
  final double viewPortBottom;

  final ChartType chartType;

  HistoryChartState({
    required final List<TimeSerial> timeSerials,
    required final bool playing,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
    required this.data,
    required this.loading,
    required this.viewPortStart,
    required this.viewPortEnd,
    required this.viewPortTop,
    required this.viewPortBottom,
    required this.chartType,
  })  : assert(viewPortStart.isBefore(viewPortEnd)),
        assert(viewPortBottom <= viewPortTop),
        viewPortWidth = viewPortEnd.difference(viewPortStart),
        viewPortHeight = computeViewPortHeight(viewPortTop, viewPortBottom),
        points = {
          for (TimeSerial ts in timeSerials)
            ts.id: data[ts.id]!
                .where((tse) => tse.value != null)
                .map(
                  (tse) => FlSpot(
                    tse.time.millisecondsSinceEpoch.toDouble(),
                    tse.value,
                  ),
                )
                .toList(),
        },
        super(
          timeSerials: timeSerials,
          visibleTimeSerials:
              visibleTimeSerials ?? timeSerials.map((e) => e.id).toList(),
          playing: playing,
        );

  static double computeViewPortHeight(
    double viewPortTop,
    double viewPortBottom,
  ) {
    double height = viewPortTop - viewPortBottom;
    if (height == 0) {
      return 1;
    }
    return height;
  }

  HistoryChartState._copy({
    required final List<TimeSerial> timeSerials,
    required final List<Pk<TimeSerial>> visibleTimeSerials,
    required final playing,
    required this.data,
    required this.loading,
    required this.viewPortStart,
    required this.viewPortEnd,
    required this.viewPortTop,
    required this.viewPortBottom,
    required this.chartType,
    required this.points,
  })  : viewPortWidth = viewPortEnd.difference(viewPortStart),
        viewPortHeight = computeViewPortHeight(viewPortTop, viewPortBottom),
        super(
          timeSerials: timeSerials,
          visibleTimeSerials: visibleTimeSerials,
          playing: playing,
        );

  @override
  HistoryChartState copyWith({
    final List<TimeSerial>? timeSerials,
    final List<Pk<TimeSerial>>? visibleTimeSerials,
    final Map<Pk<TimeSerial>, List<TimeSeriesEntry>>? data,
    final bool? loading,
    final DateTime? viewPortStart,
    final DateTime? viewPortEnd,
    final double? viewPortTop,
    final double? viewPortBottom,
    final bool? playing,
    final ChartType? chartType,
  }) {
    Map<Pk<TimeSerial>, List<FlSpot>>? newPoints;
    if (data != null && timeSerials != null) {
      if (data.length != timeSerials.length) {
        throw ArgumentError.value(data, 'data');
      }

      newPoints = {};

      for (TimeSerial ts in timeSerials) {
        newPoints[ts.id] = data[ts.id]!
            .where((tse) => tse.value != null)
            .map(
              (tse) => FlSpot(
                tse.time.millisecondsSinceEpoch.toDouble(),
                tse.value!,
              ),
            )
            .toList();
      }
    }
    return HistoryChartState._copy(
      timeSerials: timeSerials ?? this.timeSerials,
      visibleTimeSerials: visibleTimeSerials ?? this.visibleTimeSerials,
      data: data ?? this.data,
      loading: loading ?? this.loading,
      viewPortStart: viewPortStart ?? this.viewPortStart,
      viewPortEnd: viewPortEnd ?? this.viewPortEnd,
      viewPortTop: viewPortTop ?? this.viewPortTop,
      viewPortBottom: viewPortBottom ?? this.viewPortBottom,
      playing: playing ?? this.playing,
      chartType: chartType ?? this.chartType,
      points: newPoints ?? points,
    );
  }

  int getMeasurementsInWindow(final DateTime start, final DateTime stop) {
    if (points.isEmpty) {
      return 0;
    }
    final double startX = start.millisecondsSinceEpoch.toDouble();
    final double stopX = stop.millisecondsSinceEpoch.toDouble();
    return points.entries.first.value
        .where((e) => e.x >= startX && e.x <= stopX)
        .length;
  }
}
