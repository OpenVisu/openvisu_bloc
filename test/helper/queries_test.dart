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

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:test/test.dart';
import 'package:openvisu_bloc/src/helper/queries.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class MockDashboardBloc extends Mock implements DashboardBloc {}

class MockEmitter extends Mock implements Emitter<CrudState<Dashboard>> {}

class MockState extends Mock implements CrudState<Dashboard> {}

class TestQueries extends Queries<Dashboard> {}

void main() {
  final GetEvent<Dashboard> getOne1 = GetOne<Dashboard>(id: Pk<Dashboard>(1));
  final GetEvent<Dashboard> getOne2 = GetOne<Dashboard>(id: Pk<Dashboard>(2));
  const GetEvent<Dashboard> getMultiple1 = GetMultiple<Dashboard>(
    filters: [],
  );
  const GetEvent<Dashboard> getMultiple2 = GetMultiple<Dashboard>(
    filters: [Filter(key: 'dashboard_id', operator: FilterType.EQ, value: '1')],
  );

  group('Updater<T extends Model<T>>', (() {
    final TestQueries testQueries = TestQueries();
    final MockEmitter mockEmitter = MockEmitter();
    final DashboardBloc bloc = MockDashboardBloc();

    setUp(() {
      registerFallbackValue(MockState());
      testQueries.queriesInit(bloc);
    });

    test('test queriesAdd()', () {
      // adding a query the first time trigers bloc.add()
      testQueries.queriesAdd(getOne1);
      verify(() => bloc.add(getOne1)).called(1);

      // adding a query the second time must trigger bloc.add(), otherwise
      // a new widget will not recive the state
      testQueries.queriesAdd(getOne1);
      verify(() => bloc.add(getOne1)).called(1);

      // adding a different query does trigger bloc.add()
      testQueries.queriesAdd(getOne2);
      verify(() => bloc.add(getOne2)).called(1);
      verifyNever(() => bloc.add(getOne1));

      testQueries.queriesClear();
    });

    test('test queriesAdd/Remove/All/Clear()', () {
      testQueries.queriesAdd(getOne1);
      expect(testQueries.queriesAll().length, 1);
      testQueries.queriesAdd(getMultiple1);
      expect(testQueries.queriesAll().length, 2);
      testQueries.queriesRemove(getMultiple1);
      expect(testQueries.queriesAll().length, 1);
      testQueries.queriesAdd(getMultiple2);
      testQueries.queriesClear();
      expect(testQueries.queriesAll().length, 0);

      testQueries.queriesClear();
    });

    test('test queriesModelDeleted()', () {
      testQueries.queriesAdd(getOne1);
      testQueries.queriesAdd(getOne2);
      testQueries.queriesAdd(getMultiple1);
      testQueries.queriesAdd(getMultiple2);
      expect(testQueries.queriesAll().length, 4);
      reset(bloc);

      testQueries.queriesModelDeleted(Pk<Dashboard>(1), mockEmitter);
      // getOne1 query should be removed
      expect(testQueries.queriesAll().length, 3);
      // on wasDeleted error state should be emitted
      verify(() => mockEmitter(any())).called(1);
      // getMultiple should be updated
      verify(() => bloc.add(getMultiple1)).called(1);
      verify(() => bloc.add(getMultiple2)).called(1);
    });
  }));
}
