import 'package:openvisu_bloc/src/states/chart_state.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class LiveChartState extends ChartState<LiveChartState> {
  final Map<Pk<TimeSerial>, TimeSeriesEntry> values;
  final DateTime dateTime = DateTime.now();

  LiveChartState({
    required this.values,
    required final List<TimeSerial> timeSerials,
    required final List<Pk<TimeSerial>> visibleTimeSerials,
    required final bool playing,
  }) : super(
          timeSerials: timeSerials,
          visibleTimeSerials: visibleTimeSerials,
          playing: playing,
        );

  @override
  LiveChartState copyWith({
    Map<Pk<TimeSerial>, TimeSeriesEntry>? values,
    List<TimeSerial>? timeSerials,
    List<Pk<TimeSerial>>? visibleTimeSerials,
    bool? playing,
  }) =>
      LiveChartState(
        values: values ?? this.values,
        timeSerials: timeSerials ?? this.timeSerials,
        visibleTimeSerials: visibleTimeSerials ?? this.visibleTimeSerials,
        playing: playing ?? this.playing,
      );
}
