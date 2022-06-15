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
  group('SingleValuePageBloc', () {
    late CredentialsRepository credentialsRepository;
    late AuthenticationRepository authenticationRepository;
    late AuthenticationBloc authenticationBloc;

    late SingleValuePageRepository singleValuePageRepository;

    late NodeBloc nodeBloc;
    late SingleValuePageBloc singleValuePageBloc;

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

      singleValuePageRepository = SingleValuePageRepository(
        authenticationRepository: authenticationRepository,
      );

      nodeBloc = MockNodeBloc();

      singleValuePageBloc = SingleValuePageBloc(
        repository: singleValuePageRepository,
        authenticationBloc: authenticationBloc,
        nodeBloc: nodeBloc,
      );
    });

    test('initial state is InitLoadingState<SingleValuePage>()', () {
      expect(
        singleValuePageBloc.state is InitLoadingState<SingleValuePage>,
        true,
      );
    });

    blocTest<SingleValuePageBloc, CrudState<SingleValuePage>>(
      'getMultiple authenticated',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => singleValuePageBloc,
      act: (bloc) => bloc.add(const GetMultiple<SingleValuePage>(filters: [])),
      verify: (bloc) {
        expect(
          bloc.state is MultipleResultState<SingleValuePage>,
          true,
        );
        final MultipleResultState<SingleValuePage> state =
            bloc.state as MultipleResultState<SingleValuePage>;
        expect(state.error, null);
        expect(state.progress, null);
        expect(state.isLoading, false);
        expect(state.models!.isNotEmpty, true);
      },
    );

    /*
    late SingleValuePage testSingleValuePage;
    blocTest<SingleValuePageBloc, CrudState<SingleValuePage>>(
      'verify call to nodeBloc',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );

        testSingleValuePage = (await singleValuePageRepository.all([]))
            .firstWhere((element) => element.node != null);
      },
      build: () => singleValuePageBloc,
      act: (bloc) =>
          bloc.add(GetOne<SingleValuePage>(id: testSingleValuePage.id)),
      verify: (bloc) {
        expect(
          bloc.state is OneResultState<SingleValuePage>,
          true,
        );
        OneResultState<SingleValuePage> state =
            bloc.state as OneResultState<SingleValuePage>;
        verify(() => nodeBloc.set(model: state.model!.node!)).called(1);
      },
    );*/
  });
}
