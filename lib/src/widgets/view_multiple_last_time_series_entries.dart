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
import 'package:openvisu_bloc/src/cubit/multiple_time_series_entries_cubit.dart';
import 'package:openvisu_bloc/src/states/multiple_time_series_entries_state.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

typedef BuildViewWithTses = Widget Function(
  BuildContext context,
  DateTime timestamp,
  Map<Pk<TimeSerial>, TimeSeriesEntry<double?>?> models,
);

class ViewMultipleLastTimeSeriesEntries extends StatelessWidget {
  final List<Pk<TimeSerial>> ids;
  final BuildViewWithTses buildWithData;

  const ViewMultipleLastTimeSeriesEntries({
    super.key,
    required this.ids,
    required this.buildWithData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultipleTimeSeriesEntriesCubit,
        MultipleTimeSeriesEntriesState>(
      bloc: MultipleTimeSeriesEntriesCubit(
        ids: ids,
        timeSeriesEntryRepository:
            RepositoryProvider.of<TimeSeriesEntryRepository>(context),
      ),
      builder: (
        final BuildContext context,
        final MultipleTimeSeriesEntriesState state,
      ) =>
          buildWithData(context, state.timestamp, state.data),
    );
  }
}
