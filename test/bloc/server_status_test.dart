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

import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('ServerStatusBloc', () {
    blocTest<ServerStatusBloc, GetServerStatusState?>(
      'test subscribe()',
      build: () => ServerStatusBloc(const Duration(seconds: 10)),
      act: (bloc) => bloc.subscribe('http://localhost/'),
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<GetServerStatusState>()
            .having((s) => s.serverStatus.status, 'serverStatus', 'ok')
      ],
    );

    blocTest<ServerStatusBloc, GetServerStatusState?>(
      'test refresh()',
      build: () => ServerStatusBloc(const Duration(seconds: 10)),
      act: (bloc) {
        bloc.subscribe('http://localhost/');
        bloc.refresh();
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<GetServerStatusState>()
            .having((s) => s.serverStatus.status, 'serverStatus', 'ok'),
        isA<GetServerStatusState>()
            .having((s) => s.serverStatus.status, 'serverStatus', 'ok'),
      ],
    );

    blocTest<ServerStatusBloc, GetServerStatusState?>(
      'test unsubscribe()',
      build: () => ServerStatusBloc(const Duration(seconds: 10)),
      act: (bloc) {
        bloc.subscribe('http://localhost/');
        bloc.unsubscribe('http://localhost/');
        bloc.refresh();
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<GetServerStatusState>()
            .having((s) => s.serverStatus.status, 'serverStatus', 'ok'),
      ],
    );
  });
}
