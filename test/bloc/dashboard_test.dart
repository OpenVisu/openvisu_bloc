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

import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('DashboardBloc', () {
    final CredentialsRepository credentialsRepository = CredentialsRepository();
    final AuthenticationRepository authenticationRepository =
        AuthenticationRepository(
      credentialsRepository: credentialsRepository,
      httpTimeOut: const Duration(seconds: 10),
    );
    final DashboardRepository dashboardRepository = DashboardRepository(
      authenticationRepository: authenticationRepository,
    );
    final AuthenticationBloc authenticationBloc = AuthenticationBloc(
      authenticationRepository,
    );

    const Credentials credentials = Credentials(
      username: 'admin',
      password: 'password',
      endpoint: 'http://localhost/',
    );

    setUp(() async {
      await authenticationRepository.authenticate(
        credentials: credentials,
        saveLogin: false,
      );
    });

    blocTest<DashboardBloc, CrudState<Dashboard>>(
      'test GetOne<Dashboard>() success',
      build: () => DashboardBloc(
        repository: dashboardRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) => bloc.add(GetOne<Dashboard>(id: Pk<Dashboard>(1))),
      expect: () => [
        isA<OneResultState<Dashboard>>()
            .having((s) => s.id, 'test id', Pk<Dashboard>(1))
            .having((s) => s.error, 'has no error', isNull),
      ],
    );

    blocTest<DashboardBloc, CrudState<Dashboard>>(
      'test GetOne<Dashboard>() fail',
      build: () => DashboardBloc(
        repository: dashboardRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) => bloc.add(GetOne<Dashboard>(id: Pk<Dashboard>(2))),
      expect: () => [
        isA<OneResultState<Dashboard>>()
            .having((s) => s.id, 'test id', Pk<Dashboard>(2))
            .having((s) => s.error, 'has error', isNotNull),
      ],
    );
  });
}
