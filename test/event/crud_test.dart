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
  group('CrudEvent', () {
    setUp(() {});

    test('test GetOne equality', () {
      GetOne<Dashboard> state1 = GetOne<Dashboard>(id: Pk<Dashboard>(1));
      GetOne<Dashboard> state2 = GetOne<Dashboard>(id: Pk<Dashboard>(1));
      GetOne<Dashboard> state3 = GetOne<Dashboard>(id: Pk<Dashboard>(2));
      GetOne<Page> state4 = GetOne<Page>(id: Pk<Page>(1));

      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
      expect(state1 == state4, false);
    });

    test('test SetOne equality', () {
      SetOne<Dashboard> state1 = SetOne<Dashboard>(
        model: Dashboard.createDefault(),
      );
      SetOne<Dashboard> state2 = SetOne<Dashboard>(
        model: Dashboard.createDefault(),
      );
      SetOne<Dashboard> state3 = SetOne<Dashboard>(
        model: Dashboard.createDefault().copyWith(name: 'test'),
      );
      SetOne<Page> state4 = SetOne<Page>(model: Page.createDefault());

      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
      expect(state1 == state4, false);
    });

    test('test GetMultiple equality', () {
      GetMultiple<Dashboard> state1 = const GetMultiple<Dashboard>(filters: []);
      GetMultiple<Dashboard> state2 = const GetMultiple<Dashboard>(filters: []);
      GetMultiple<Dashboard> state3 =
          const GetMultiple<Dashboard>(filters: null);
      GetMultiple<Page> state4 = const GetMultiple<Page>(filters: []);

      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
      expect(state1 == state4, false);
    });

    test('test Save equality', () {
      Save<Dashboard> state1 = Save<Dashboard>(
        model: Dashboard.createDefault(),
      );
      Save<Dashboard> state2 = Save<Dashboard>(
        model: Dashboard.createDefault(),
      );
      Save<Dashboard> state3 = Save<Dashboard>(
        model: Dashboard.createDefault().copyWith(name: 'test'),
      );
      Save<Page> state4 = Save<Page>(model: Page.createDefault());

      expect(state1 == state2, true);
      expect(state1 == state3, false);
      expect(state3 == state3, true);
      expect(state1 == state4, false);
    });
  });
}
