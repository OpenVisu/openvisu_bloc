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

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_bloc/src/cubit/view_window_on_measurements_cubit.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

typedef BuildViewWithMeasurements = Widget Function(
  BuildContext context,
  ViewWindowOnMeasurementsControler cubit,
  MultipleMeasurementsState state,
);

class ViewWindowOnMeasurements extends StatelessWidget {
  final List<Pk<TimeSerial>> timeSerialIds;
  final Duration viewPortWidth;
  final BuildViewWithMeasurements buildWithData;

  const ViewWindowOnMeasurements({
    super.key,
    required this.timeSerialIds,
    required this.viewPortWidth,
    required this.buildWithData,
  });

  @override
  Widget build(BuildContext context) {
    final ViewWindowOnMeasurementsCubit cubit = ViewWindowOnMeasurementsCubit(
      timeSerialIds: timeSerialIds,
      viewPortWidth: viewPortWidth,
      measurementsRepository:
          RepositoryProvider.of<MeasurementsRepository>(context),
    );
    return BlocBuilder<ViewWindowOnMeasurementsCubit,
        MultipleMeasurementsState>(
      bloc: cubit,
      builder: (context, state) => buildWithData(context, cubit, state),
    );
  }
}
