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
import 'package:openvisu_repository/openvisu_repository.dart';

class OvRepositoryProviders extends StatelessWidget {
  final Widget child;
  final AuthenticationRepository authenticationRepository;
  final CredentialsRepository credentialsRepository;
  final ServerStatusRepository serverStatusRepository;

  late final List<RepositoryProvider> providers;

  OvRepositoryProviders({
    Key? key,
    required this.child,
    required this.authenticationRepository,
    required this.credentialsRepository,
    required this.serverStatusRepository,
  }) : super(key: key) {
    final NodeRepository nodeRepository = NodeRepository(
      authenticationRepository: authenticationRepository,
    );
    final TimeSeriesEntryRepository timeSeriesEntryRepository =
        TimeSeriesEntryRepository();
    final MeasurementsRepository measurementsRepository =
        MeasurementsRepository(
      timeSeriesEntryRepository: timeSeriesEntryRepository,
    );
    final TimeSerialRepository timeSerialRepository = TimeSerialRepository(
      authenticationRepository: authenticationRepository,
      measurementsRepository: measurementsRepository,
    );

    providers = [
      RepositoryProvider<AuthenticationRepository>(
        create: (_) => authenticationRepository,
      ),
      RepositoryProvider<CredentialsRepository>(
        create: (_) => credentialsRepository,
      ),
      RepositoryProvider<ServerStatusRepository>(
        create: (_) => serverStatusRepository,
      ),
      RepositoryProvider<TimeSeriesEntryRepository>(
        create: (_) => timeSeriesEntryRepository,
      ),
      RepositoryProvider<MeasurementsRepository>(
        create: (_) => measurementsRepository,
      ),
      RepositoryProvider<DashboardRepository>(
        create: (context) => DashboardRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<PageRepository>(
        create: (context) => PageRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<RoleRepository>(
        create: (context) => RoleRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<UserRepository>(
        create: (context) => UserRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<ServerRepository>(
        create: (context) => ServerRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<NodeRepository>(
        create: (_) => nodeRepository,
      ),
      RepositoryProvider<TextPageRepository>(
        create: (context) => TextPageRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<IframePageRepository>(
        create: (context) => IframePageRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<SettingRepository>(
        create: (context) => SettingRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<TimeSerialRepository>(
        create: (context) => timeSerialRepository,
      ),
      RepositoryProvider<ChartPageRepository>(
        create: (context) => ChartPageRepository(
          authenticationRepository: authenticationRepository,
          timeSerialRepository: timeSerialRepository,
        ),
      ),
      RepositoryProvider<SingleValuePageRepository>(
        create: (context) => SingleValuePageRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<ImagePageRepository>(
        create: (context) => ImagePageRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<LibraryEntryRepository>(
        create: (context) => LibraryEntryRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<IFrameRepository>(
        create: (context) => IFrameRepository(
          authenticationRepository: authenticationRepository,
        ),
      ),
      RepositoryProvider<ProjectRepository>(
        create: (context) => ProjectRepository(
            authenticationRepository: authenticationRepository),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: providers,
      child: child,
    );
  }
}
