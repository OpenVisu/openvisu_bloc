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

class MockNodeBloc extends Mock implements NodeBloc {}

void main() {
  group('AuthenticationBloc', () {
    late CredentialsRepository credentialsRepository;
    late AuthenticationRepository authenticationRepository;
    late AuthenticationBloc authenticationBloc;

    late NodeBloc nodeBloc;

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
      authenticationBloc = AuthenticationBloc(authenticationRepository);

      nodeBloc = MockNodeBloc();
    });

    test('initial state is InitLoadingState<AuthenticationUninitialized>()',
        () {
      expect(
        authenticationBloc.state is AuthenticationUninitialized,
        true,
      );
    });

    /*
    blocTest<AuthenticationBloc, AuthenticationState>(
      'test if unauthenticated is detected after start',
      setUp: () async {
        await authenticationRepository.doLogout();
      },
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        isA<AuthenticationUnauthenticated>(),
      ],
    );*/

    blocTest<AuthenticationBloc, AuthenticationState>(
      'test if authenticated is detected after start',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        isA<AuthenticationAuthenticated>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'test logout',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(DoLogOut()),
      expect: () => [
        isA<AuthenticationLoading>(),
        isA<AuthenticationUnauthenticated>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'test if other blocs are reset after logout',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
        authenticationBloc.registerBloc(nodeBloc);
        expect(authenticationBloc.blocs.length, 1);
      },
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(DoLogOut()),
      expect: () => [
        isA<AuthenticationLoading>(),
        isA<AuthenticationUnauthenticated>(),
      ],
      verify: (bloc) {
        verify(() => nodeBloc.reset()).called(1);
      },
    );
  });
}
