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
  group('VisibleTimeSerialsCubit', () {
    final List<Pk<TimeSerial>> availableTimeSerials = [
      Pk<TimeSerial>(1),
      Pk<TimeSerial>(2),
      Pk<TimeSerial>(3),
    ];
    final List<Pk<TimeSerial>> availableTimeSerials2 = [
      Pk<TimeSerial>(1),
      Pk<TimeSerial>(3),
      Pk<TimeSerial>(2),
    ];

    final List<Pk<TimeSerial>> availableTimeSerials3 = [
      Pk<TimeSerial>(1),
      Pk<TimeSerial>(2),
      Pk<TimeSerial>(3),
      Pk<TimeSerial>(4),
    ];

    blocTest<VisibleTimeSerialsCubit, VisibleTimeSerialsState>(
      'test updateTimeSerials()',
      build: () => VisibleTimeSerialsCubit(),
      act: (bloc) {
        bloc.updateTimeSerials(availableTimeSerials);
        bloc.updateTimeSerials(availableTimeSerials3);
        bloc.updateTimeSerials(availableTimeSerials);
      },
      expect: () => [
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 4)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 4),
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
      ],
    );

    blocTest<VisibleTimeSerialsCubit, VisibleTimeSerialsState>(
      'test hideTimeSerial()',
      build: () => VisibleTimeSerialsCubit(),
      act: (bloc) {
        bloc.updateTimeSerials(availableTimeSerials);
        bloc.hideTimeSerial(availableTimeSerials[1]);
      },
      expect: () => [
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 2),
      ],
    );

    blocTest<VisibleTimeSerialsCubit, VisibleTimeSerialsState>(
      'test showTimeSerial()',
      build: () => VisibleTimeSerialsCubit(),
      act: (bloc) {
        bloc.updateTimeSerials(availableTimeSerials);
        bloc.hideTimeSerial(availableTimeSerials[1]);
        bloc.showTimeSerial(availableTimeSerials[1]);
      },
      expect: () => [
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 2),
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
      ],
    );

    blocTest<VisibleTimeSerialsCubit, VisibleTimeSerialsState>(
      'test updateTimeSerials() to dectect identical lists',
      build: () => VisibleTimeSerialsCubit(),
      act: (bloc) {
        bloc.updateTimeSerials(availableTimeSerials);
        bloc.updateTimeSerials(availableTimeSerials2);
      },
      expect: () => [
        isA<VisibleTimeSerialsState>()
            .having((s) => s.availableTimeSerials.length,
                'availableTimeSerials.length', 3)
            .having((s) => s.visibleTimeSerials.length,
                'visibleTimeSerials.length', 3),
      ],
    );
  });
}
