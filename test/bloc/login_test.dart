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

class MockCredentialsRepository extends Mock implements CredentialsRepository {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockCredentials extends Mock implements Credentials {}

void main() {
  group('LoginBloc', () {
    final CredentialsRepository mockCredentialsRepository =
        MockCredentialsRepository();

    final AuthenticationRepository authenticationRepository =
        AuthenticationRepository(
      credentialsRepository: mockCredentialsRepository,
      httpTimeOut: const Duration(seconds: 10),
    );
    final MockAuthenticationBloc mockAuthenticationBloc =
        MockAuthenticationBloc();

    const Credentials credentialsGood = Credentials(
      username: 'admin',
      password: 'password',
      endpoint: 'http://localhost/',
    );

    const Credentials credentialsBad = Credentials(
      username: 'Admin',
      password: '12345',
      endpoint: 'http://localhost/',
    );

    setUpAll(() {
      registerFallbackValue(LoggedIn());
      registerFallbackValue(MockCredentials());
    });

    blocTest<LoginBloc, LoginState>(
      'test LoginButtonPressed with bad credentials',
      build: () => LoginBloc(
        authenticationRepository,
        mockAuthenticationBloc,
      ),
      act: (bloc) => bloc.add(
        const LoginButtonPressed(
          credentials: credentialsBad,
          saveLogin: true,
        ),
      ),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginFailure>().having((s) => s.error, 'error', isNotNull),
      ],
      verify: (bloc) {
        verifyNever(() => mockAuthenticationBloc.add(any()));
        verifyNever(() => mockCredentialsRepository.add(credentialsBad));
      },
    );

    blocTest<LoginBloc, LoginState>(
      'test LoginButtonPressed with good credentials',
      build: () => LoginBloc(
        authenticationRepository,
        mockAuthenticationBloc,
      ),
      act: (bloc) => bloc.add(
        const LoginButtonPressed(
          credentials: credentialsGood,
          saveLogin: false,
        ),
      ),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginInitial>(),
      ],
      verify: (bloc) {
        verify(() => mockAuthenticationBloc.add(any())).called(1);
        verifyNever(() => mockCredentialsRepository.add(credentialsGood));
      },
    );
  });
}
