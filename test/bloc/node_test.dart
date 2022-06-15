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
  group('NodeBloc', () {
    late CredentialsRepository credentialsRepository;
    late AuthenticationRepository authenticationRepository;
    late AuthenticationBloc authenticationBloc;

    late NodeRepository nodeRepository;

    late NodeBloc nodeBloc;

    final Credentials credentials = Credentials(
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

      nodeRepository = NodeRepository(
        authenticationRepository: authenticationRepository,
      );

      nodeBloc = NodeBloc(
        repository: nodeRepository,
        authenticationBloc: authenticationBloc,
      );
    });

    test('initial state is InitLoadingState<Node>()', () {
      expect(
        nodeBloc.state is InitLoadingState<Node>,
        true,
      );
    });

    late Pk<Node> nodeId;

    blocTest<CrudBloc<Node>, CrudState<Node>>(
      'getMultiple authenticated',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => nodeBloc,
      act: (bloc) => bloc.add(const GetMultiple<Node>(filters: [])),
      verify: (bloc) {
        expect(
          bloc.state is MultipleResultState<Node>,
          true,
        );
        final MultipleResultState<Node> state =
            bloc.state as MultipleResultState<Node>;
        expect(state.error, null);
        expect(state.progress, null);
        expect(state.isLoading, false);
        expect(state.models!.isNotEmpty, true);

        nodeId = state.models!.first.id;
      },
    );

    blocTest<CrudBloc<Node>, CrudState<Node>>(
      'getOne authenticated',
      setUp: () async {
        await authenticationRepository.authenticate(
          credentials: credentials,
          saveLogin: false,
        );
      },
      build: () => nodeBloc,
      act: (bloc) => bloc.add(GetOne<Node>(id: nodeId)),
      verify: (bloc) {
        expect(
          bloc.state is OneResultState<Node>,
          true,
        );
        final OneResultState<Node> state = bloc.state as OneResultState<Node>;
        expect(state.id, nodeId);
      },
    );
  });
}
