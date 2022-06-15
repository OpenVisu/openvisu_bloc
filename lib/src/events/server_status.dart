class GetServerStatusEvent {
  final String serverUrl;

  GetServerStatusEvent(this.serverUrl);

  @override
  bool operator ==(other) {
    if (other is! GetServerStatusEvent) {
      return false;
    }
    return serverUrl == other.serverUrl;
  }

  @override
  int get hashCode => serverUrl.hashCode;
}
