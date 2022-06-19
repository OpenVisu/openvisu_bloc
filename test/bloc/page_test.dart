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
  group('PageBloc', () {
    final CredentialsRepository credentialsRepository = CredentialsRepository();
    final AuthenticationRepository authenticationRepository =
        AuthenticationRepository(
      credentialsRepository: credentialsRepository,
      httpTimeOut: const Duration(seconds: 10),
    );
    final PageRepository pageRepository = PageRepository(
      authenticationRepository: authenticationRepository,
    );
    final AuthenticationBloc authenticationBloc = AuthenticationBloc(
      authenticationRepository,
    );

    const Credentials credentials = Credentials(
      username: 'admin',
      password: 'password',
      endpoint: 'http://localhost/',
    );

    setUp(() async {
      await authenticationRepository.authenticate(
        credentials: credentials,
        saveLogin: false,
      );
    });
    /*

    blocTest<PageBloc, CrudState<Page>>(
      'test GetOne<Dashboard>() success',
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) => bloc.add(GetOne<Page>(id: Pk<Page>(1))),
      expect: () => [
        isA<OneResultState<Page>>()
            .having((s) => s.id, 'test id', Pk<Page>(1))
            .having((s) => s.error, 'has no error', isNull),
      ],
    );

    blocTest<PageBloc, CrudState<Page>>(
      'test GetOne<Dashboard>() fail',
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) => bloc.add(GetOne<Page>(id: Pk<Page>(2))),
      expect: () => [
        isA<OneResultState<Page>>()
            .having((s) => s.id, 'test id', Pk<Page>(2))
            .having((s) => s.error, 'has error', isNotNull),
      ],
    );*/

    /// if a new model is added, active queries that might be affected
    /// should automatically be updated
    blocTest<PageBloc, CrudState<Page>>(
      'test Save<Page>() for new model',
      build: () {
        final PageBloc bloc = PageBloc(
          repository: pageRepository,
          authenticationBloc: authenticationBloc,
        );
        bloc.addListener(GetMultiple<Page>(
          filters: [
            Filter(
              key: 'dashboard_id',
              operator: FilterType.EQ,
              value: Pk<Dashboard>(1).toString(),
            ),
          ],
        ));
        return bloc;
      },
      act: (bloc) => bloc.add(
        Save<Page>(
          model: Page.createDefault().copyWith(
            name: 'new test page',
            dashboardId: Pk<Dashboard>(1),
            pageType: PageType.text,
          ),
        ),
      ),
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<OneResultState<Page>>()
            .having((s) => s.isSaved, 'test isSaved', false)
            .having((s) => s.model!.isNew, 'test if model isNew', true),
        isA<OneResultState<Page>>()
            .having((s) => s.isSaved, 'test isSaved', true)
            .having((s) => s.model, 'test if model exists', isNotNull)
            .having(
              (s) => s.model!.dashboardId,
              'dashboardId',
              Pk<Dashboard>(1),
            ),
        isA<MultipleResultState<Page>>().having(
          (s) => s.models,
          'test if models exist',
          isNotNull,
        )
      ],
      tearDown: () async {
        List<Pk<Page>> pageIds =
            (await pageRepository.all([])).map((e) => e.id).toList();
        pageRepository.delete(pageIds.last);
      },
    );
  });
}
