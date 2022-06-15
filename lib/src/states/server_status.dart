import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class GetServerStatusState {
  final GetServerStatusEvent getEvent;
  final ServerStatus serverStatus;

  GetServerStatusState(this.getEvent, this.serverStatus);
}
