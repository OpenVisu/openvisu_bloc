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
      tearDown: () {
        pageRepository.cacheClear();
      },
    );

    blocTest<PageBloc, CrudState<Page>>(
      'test GetOne<Dashboard>() fail',
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) => bloc.add(GetOne<Page>(id: Pk<Page>(12345))),
      expect: () => [
        isA<OneResultState<Page>>()
            .having((s) => s.id, 'test id', Pk<Page>(12345))
            .having((s) => s.error, 'has error', isNotNull),
      ],
      tearDown: () {
        pageRepository.cacheClear();
      },
    );

    /// if a new model is added, active queries that might be affected
    /// should automatically be updated
    blocTest<PageBloc, CrudState<Page>>(
      'test Save<Page>() for new model',
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) {
        bloc.queriesAdd(
          GetMultiple<Page>(
            filters: [
              Filter(
                key: 'dashboard_id',
                operator: FilterType.EQ,
                value: Pk<Dashboard>(1).toString(),
              ),
            ],
          ),
          periodicUpdate: false,
        );
        bloc.add(
          Save<Page>(
            model: Page.createDefault().copyWith(
              name: 'new test page',
              dashboardId: Pk<Dashboard>(1),
              pageType: PageType.text,
            ),
          ),
        );
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        isA<MultipleResultState<Page>>(),
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
        ),
        isA<MultipleResultState<Page>>(),
      ],
      verify: (bloc) {
        // bloc needed to tearDown
        bloc.queriesRemove(
          GetMultiple<Page>(
            filters: [
              Filter(
                key: 'dashboard_id',
                operator: FilterType.EQ,
                value: Pk<Dashboard>(1).toString(),
              ),
            ],
          ),
          periodicUpdate: true,
        );
      },
      tearDown: () {
        pageRepository.cacheClear();
      },
    );

    /// helper var to temporarily store the current page used by the tests
    late Page page;

    /// test if updateing a model updates GetOne<Page> and
    /// GetMultiple<Page> queries
    blocTest<PageBloc, CrudState<Page>>(
      'test Save<Page>() for existing model',
      setUp: () async {
        page = Page.createDefault().copyWith(
          name: 'test name',
          dashboardId: Pk<Dashboard>(1),
          pageType: PageType.text,
        );
        page = await pageRepository.add(page);
        pageRepository.cacheClear();
      },
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) {
        bloc.queriesAdd(GetOne<Page>(id: page.id));
        bloc.queriesAdd(const GetMultiple<Page>(filters: []));
        bloc.add(Save<Page>(model: page.copyWith(name: 'new test name')));
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        // one states because of queriesAdd(GetOne<Page>)
        isA<OneResultState<Page>>()
            .having((s) => s.isSaved, 'isSaved', true)
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.model!.name, 'model.name', 'test name'),
        // first state because of queriesAdd(GetMultiple<Page>)
        isA<MultipleResultState<Page>>()
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', false),

        // first state because of Save<Page>()
        isA<OneResultState<Page>>()
            .having((s) => s.isSaved, 'isSaved', false)
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.model!.name, 'model.name', 'new test name'),
        // second state because of Save<Page>()
        isA<OneResultState<Page>>()
            .having((s) => s.isSaved, 'isSaved', true)
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.model!.name, 'model.name', 'new test name'),
        // third state because of Save<Page>()
        isA<MultipleResultState<Page>>()
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', true),
        isA<MultipleResultState<Page>>()
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      tearDown: () async {
        await pageRepository.delete(page.id);
        pageRepository.cacheClear();
      },
    );

    /// test if model gets deleted
    blocTest<PageBloc, CrudState<Page>>(
      'test Delete<Page>()',
      setUp: () async {
        page = Page.createDefault().copyWith(
          name: 'test name',
          dashboardId: Pk<Dashboard>(1),
          pageType: PageType.text,
        );
        page = await pageRepository.add(page);
      },
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) {
        bloc.add(Delete<Page>(model: page));
      },
      verify: (bloc) async {
        expect(
          () async {
            await pageRepository.get(page.id);
          },
          throwsA(
            isA<BackendError>().having(
              (e) => (e.info as YiiExceptionInformation).message,
              'message',
              startsWith('Object not found: '),
            ),
          ),
        );
      },
      tearDown: () {
        pageRepository.cacheClear();
      },
    );

    /// deleting a model should notify all active queries on that model
    /// that the model was deleted
    blocTest<PageBloc, CrudState<Page>>(
      'test Delete<Page>() with active GetOne<Page>() query',
      setUp: () async {
        page = Page.createDefault().copyWith(
          name: 'test name',
          dashboardId: Pk<Dashboard>(1),
          pageType: PageType.text,
        );
        page = await pageRepository.add(page);
        pageRepository.cacheClear();
      },
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) {
        bloc.queriesAdd(GetOne<Page>(id: page.id));
        bloc.add(Delete<Page>(model: page));
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        // one state because of queriesAdd
        isA<OneResultState<Page>>()
            .having((s) => s.model, 'model', isNotNull)
            .having((s) => s.isLoading, 'isLoading', false),
        // one state created because of Delete<Page>
        isA<OneResultState<Page>>()
            .having((s) => s.error, 'test error', isNotNull)
            .having((s) => s.isSaved, 'isSaved', true)
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.error,
              'test if error indicates delete',
              isA<YiiErrorInformation>().having(
                (e) => e.message,
                'message',
                'The Item was deleted',
              ),
            ),
      ],
      tearDown: () {
        pageRepository.cacheClear();
      },
    );

    /// deleting a model should notify all active queries that might include
    /// the model that the model was deleted
    blocTest<PageBloc, CrudState<Page>>(
      'test Delete<Page>() with active GetMultiple<Page>() query',
      setUp: () async {
        page = Page.createDefault().copyWith(
          name: 'test name',
          dashboardId: Pk<Dashboard>(1),
          pageType: PageType.text,
        );
        page = await pageRepository.add(page);
      },
      build: () => PageBloc(
        repository: pageRepository,
        authenticationBloc: authenticationBloc,
      ),
      act: (bloc) {
        bloc.queriesAdd(const GetMultiple<Page>(filters: []));
        bloc.add(Delete<Page>(model: page));
      },
      wait: const Duration(seconds: 10),
      expect: () => [
        // one state because of queriesAdd
        isA<MultipleResultState<Page>>()
            .having((s) => s.error, 'error', isNull)
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', false),
        // two states created because of Delete<Page>
        isA<MultipleResultState<Page>>()
            .having((s) => s.error, 'error', isNull)
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', true),
        isA<MultipleResultState<Page>>()
            .having((s) => s.error, 'error', isNull)
            .having((s) => s.hasData, 'hasData', true)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      tearDown: () {
        pageRepository.cacheClear();
      },
    );
  });
}
