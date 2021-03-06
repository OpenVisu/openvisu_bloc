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

// ignore_for_file: unrelated_type_equality_checks

import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

import 'package:test/test.dart';

void main() {
  group('CrudState', () {
    setUp(() {});

    test('test InitLoadingState equality', () {
      InitLoadingState<Dashboard> state1 = const InitLoadingState<Dashboard>();
      InitLoadingState<Dashboard> state2 = const InitLoadingState<Dashboard>();
      InitLoadingState<Page> state3 = const InitLoadingState<Page>();

      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
    });

    test('test OneResultState equality', () {
      OneResultState<Dashboard> state1 = const OneResultState<Dashboard>(
        isLoading: false,
        isSaved: false,
      );
      OneResultState<Dashboard> state2 = const OneResultState<Dashboard>(
        isLoading: false,
        isSaved: false,
      );
      OneResultState<Dashboard> state3 = const OneResultState<Dashboard>(
        isLoading: true,
        isSaved: false,
      );
      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
    });
  });

  test('test MultipleResultState equality', () {
    MultipleResultState<Dashboard> state1 =
        const MultipleResultState<Dashboard>(
      isLoading: false,
    );
    MultipleResultState<Dashboard> state2 =
        const MultipleResultState<Dashboard>(
      isLoading: false,
    );
    MultipleResultState<Page> state3 = const MultipleResultState<Page>(
      isLoading: false,
    );

    expect(state1 == state2, true);
    expect(state1 == state3, false);
    expect(state3 == state3, true);
  });

  test('test LoadedFileState equality', () {
    LoadedFileState<Dashboard> state1 = const LoadedFileState<Dashboard>(
      path: 'test',
    );
    LoadedFileState<Dashboard> state2 = const LoadedFileState<Dashboard>(
      path: 'test',
    );
    LoadedFileState<Dashboard> state3 = const LoadedFileState<Dashboard>(
      path: 'test2',
    );

    expect(state1 == state2, true);
    expect(state1 == state3, false);
    expect(state3 == state3, true);
  });
}
