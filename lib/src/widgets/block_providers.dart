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
import 'package:openvisu_repository/openvisu_repository.dart';

class OvBlocProviders extends StatelessWidget {
  final Widget child;

  final AuthenticationBloc authenticationBloc;
  late final List<BlocProvider> providers;
  final Duration httpTimeOut;

  OvBlocProviders({
    Key? key,
    required this.authenticationBloc,
    required this.child,
    required this.httpTimeOut,
  }) : super(key: key) {
    providers = [
      BlocProvider<AuthenticationBloc>(
        create: (BuildContext context) => authenticationBloc,
      ),
      BlocProvider<DashboardBloc>(
        create: (BuildContext context) => DashboardBloc(
          repository: RepositoryProvider.of<DashboardRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<PageBloc>(
        create: (BuildContext context) => PageBloc(
          repository: RepositoryProvider.of<PageRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<RoleBloc>(
        create: (BuildContext context) => RoleBloc(
          repository: RepositoryProvider.of<RoleRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<UserBloc>(
        create: (BuildContext context) => UserBloc(
          repository: RepositoryProvider.of<UserRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<ServerBloc>(
        create: (BuildContext context) => ServerBloc(
          repository: RepositoryProvider.of<ServerRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<NodeBloc>(
        create: (BuildContext context) => NodeBloc(
          repository: RepositoryProvider.of<NodeRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<TextPageBloc>(
        create: (BuildContext context) => TextPageBloc(
          repository: RepositoryProvider.of<TextPageRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<IframePageBloc>(
        create: (BuildContext context) => IframePageBloc(
          repository: RepositoryProvider.of<IframePageRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<SettingBloc>(
        create: (BuildContext context) => SettingBloc(
          repository: RepositoryProvider.of<SettingRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<ChartPageBloc>(
        create: (BuildContext context) => ChartPageBloc(
          repository: RepositoryProvider.of<ChartPageRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<TimeSerialBloc>(
        create: (BuildContext context) => TimeSerialBloc(
          repository: RepositoryProvider.of<TimeSerialRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<SingleValuePageBloc>(
        create: (BuildContext context) => SingleValuePageBloc(
          repository: RepositoryProvider.of<SingleValuePageRepository>(context),
          nodeBloc: BlocProvider.of<NodeBloc>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<ImagePageBloc>(
        create: (BuildContext context) => ImagePageBloc(
          repository: RepositoryProvider.of<ImagePageRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<LibraryEntryBloc>(
        create: (BuildContext context) => LibraryEntryBloc(
          repository: RepositoryProvider.of<LibraryEntryRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<IFrameBloc>(
        create: (BuildContext context) => IFrameBloc(
          repository: RepositoryProvider.of<IFrameRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
      BlocProvider<ServerStatusBloc>(
        create: (_) => ServerStatusBloc(httpTimeOut),
      ),
      BlocProvider<ProjectBloc>(
        create: (BuildContext context) => ProjectBloc(
          repository: RepositoryProvider.of<ProjectRepository>(context),
          authenticationBloc: authenticationBloc,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: providers, child: child);
  }
}
