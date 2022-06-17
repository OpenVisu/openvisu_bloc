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
import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:test/test.dart';
import 'package:openvisu_bloc/src/helper/updater.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

class MockDashboardBloc extends Mock implements DashboardBloc {}

class TestUpdater extends Updater<Dashboard> {}

void main() {
  final GetEvent<Dashboard> get1 = GetOne<Dashboard>(id: Pk<Dashboard>(1));
  final GetEvent<Dashboard> get2 = GetOne<Dashboard>(id: Pk<Dashboard>(2));

  group('Updater<T extends Model<T>>', (() {
    final TestUpdater testUpdater = TestUpdater();
    final DashboardBloc bloc = MockDashboardBloc();

    setUp(() {
      testUpdater.updaterInit(bloc, interval: const Duration(seconds: 1));
    });

    test('test addListener()', () async {
      testUpdater.addListener(get1);
      testUpdater.addListener(get2);
      expect(testUpdater.timer.isActive, true);
    });

    test('test removeListener()', () {
      testUpdater.removeListener(get1);
      expect(testUpdater.timer.isActive, true);
      testUpdater.removeListener(get2);
      expect(testUpdater.timer.isActive, false);
    });

    test('test update()', () {
      testUpdater.addListener(get1);
      testUpdater.addListener(get2);
      testUpdater.update();

      verify(() => bloc.add(get1)).called(1);
      verify(() => bloc.add(get2)).called(1);

      testUpdater.removeListener(get1);
      testUpdater.update();
      verifyNever(() => bloc.add(get1));
      verify(() => bloc.add(get2)).called(1);

      testUpdater.removeListener(get2);
      testUpdater.update();
      verifyNever(() => bloc.add(get1));
      verifyNever(() => bloc.add(get2));
    });
  }));
}
