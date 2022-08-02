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
  group('NodeSearchCubit', () {
    final CredentialsRepository credentialsRepository = CredentialsRepository();
    final AuthenticationRepository authenticationRepository =
        AuthenticationRepository(
      credentialsRepository: credentialsRepository,
      httpTimeOut: const Duration(seconds: 10),
    );

    final NodeRepository nodeRepository =
        NodeRepository(authenticationRepository: authenticationRepository);

    const Credentials credentials = Credentials(
      username: 'admin',
      password: 'password',
      endpoint: 'http://localhost/',
    );

    setUpAll(() async {
      await authenticationRepository.authenticate(
        credentials: credentials,
        saveLogin: false,
      );
    });

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test init',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<NodeSearchState>() //
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 20),
      ],
    );

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test search() tracked: true',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      act: (bloc) {
        bloc.setTracked(true);
      },
      expect: () => [
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 4),
      ],
    );

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test search() dataType: Int32',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      act: (bloc) {
        bloc.setDataType(DataType.Int32);
      },
      expect: () => [
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 1),
      ],
    );

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test search() displayName: exact match',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      act: (bloc) {
        bloc.setDisplayName('TestVarInt32');
      },
      expect: () => [
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 1),
      ],
    );

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test search() displayName: lowercase match',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      act: (bloc) {
        bloc.setDisplayName('testvarint32');
      },
      expect: () => [
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 1),
      ],
    );

    blocTest<NodeSearchCubit, NodeSearchState>(
      'test search() displayName: partly match',
      build: () => NodeSearchCubit(nodeRepository: nodeRepository),
      wait: const Duration(seconds: 10),
      act: (bloc) {
        bloc.setDisplayName('varint32');
      },
      expect: () => [
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', false)
            .having((s) => s.loading, 'loading', true),
        isA<NodeSearchState>()
            .having((s) => s.totalResultCount, 'totalResultCount', isNull)
            .having((s) => s.finished, 'finished', true)
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.results.length, 'results.length', 1),
      ],
    );

    tearDownAll(() async {
      await authenticationRepository.doLogout();
    });
  });
}
