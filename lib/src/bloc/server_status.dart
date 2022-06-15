import 'dart:async';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ServerStatusBloc
    extends Bloc<GetServerStatusEvent, GetServerStatusState?> {
  late final ServerStatusRepository serverStatusRepository =
      ServerStatusRepository(httpTimeOut);
  Timer timer = Timer(Duration.zero, () {});

  final Duration httpTimeOut;

  ServerStatusBloc(this.httpTimeOut) : super(null) {
    super.on<GetServerStatusEvent>(_getServerStatus);
  }

  Future<void> _getServerStatus(
    GetServerStatusEvent event,
    Emitter<GetServerStatusState?> emit,
  ) async {
    final ServerStatus serverStatus = await serverStatusRepository.get(
      event.serverUrl,
    );
    emit(GetServerStatusState(event, serverStatus));
  }

  final Map<String, int> serverListenerCount = {};

  void subscribe(final String server) {
    if (!serverListenerCount.containsKey(server)) {
      serverListenerCount[server] = 1;
      add(GetServerStatusEvent(server));
    } else {
      serverListenerCount[server] = serverListenerCount[server]! + 1;
    }
    if (serverListenerCount.isNotEmpty) {
      if (!timer.isActive) {
        timer = Timer.periodic(
          const Duration(minutes: 1),
          (Timer t) => refresh(),
        );
      }
    }
  }

  void unsubscribe(final String server) {
    if (!serverListenerCount.containsKey(server)) {
      return;
    } else {
      serverListenerCount[server] = serverListenerCount[server]! - 1;
      if (serverListenerCount[server] == 0) {
        serverListenerCount.remove(server);
      }
    }
    if (serverListenerCount.isEmpty) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
  }

  void refresh() {
    for (final String server in serverListenerCount.keys) {
      add(GetServerStatusEvent(server));
    }
  }
}
