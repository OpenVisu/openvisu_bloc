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

import 'package:mocktail/mocktail.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('DashboardBloc', () {
    late CredentialsRepository credentialsRepository;
    late AuthenticationRepository authenticationRepository;
    late DashboardRepository dashboardRepository;
    late AuthenticationBloc authenticationBloc;
    late DashboardBloc dashboardBloc;

    const Credentials credentials = Credentials(
      username: 'admin',
      password: 'password',
      endpoint: 'http://localhost/',
    );

    setUp(() {
      credentialsRepository = CredentialsRepository();
      authenticationRepository = AuthenticationRepository(
        credentialsRepository: credentialsRepository,
        httpTimeOut: const Duration(seconds: 10),
      );
      dashboardRepository = DashboardRepository(
        authenticationRepository: authenticationRepository,
      );
      authenticationBloc = AuthenticationBloc(authenticationRepository);

      dashboardBloc = DashboardBloc(
        repository: dashboardRepository,
        authenticationBloc: authenticationBloc,
      );
    });

    blocTest<DashboardBloc, CrudState<Dashboard>>(
      'test if authenticated is detected after start',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(GetOne<Dashboard>(id: Pk<Dashboard>(1))),
      expect: () => [
        isA<OneResultState<Dashboard>>(),
      ],
    );
  });
}
