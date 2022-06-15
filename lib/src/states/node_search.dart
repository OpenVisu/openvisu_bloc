import 'package:openvisu_repository/openvisu_repository.dart';

class NodeSearchState {
  final List<Node> results;

  /// indicate if data are loaded at the moment
  final bool loading;

  /// total number of matching nodes, if null => unknown
  final int? totalResultCount;

  /// the number of loaded pages
  final int pageCount;

  final String displayName;
  final String nodeId;
  final bool? tracked;
  final Pk<Server> serverId;
  final DataType dataType;

  /// indicates that no more data can be loaded // end of pagination
  /// workaround for as long as totalResultCount is unknown
  final bool finished;

  NodeSearchState()
      : results = [],
        loading = false,
        pageCount = 0,
        totalResultCount = null,
        displayName = '',
        nodeId = '',
        tracked = null,
        serverId = const Pk<Server>.empty(),
        dataType = DataType.none,
        finished = false;

  NodeSearchState._copy({
    required this.results,
    required this.loading,
    required this.pageCount,
    required this.totalResultCount,
    required this.displayName,
    required this.nodeId,
    required this.tracked,
    required this.serverId,
    required this.dataType,
    required this.finished,
  });

  /// search values must be always provided because they are nullable
  NodeSearchState copyWith({
    final List<Node>? results,
    final bool? loading,
    final int? pageCount,
    required final int? totalResultCount,
    final String? displayName,
    final String? nodeId,
    required final bool? tracked,
    final DataType? dataType,
    final Pk<Server>? serverId,
    final bool? finished,
  }) =>
      NodeSearchState._copy(
        results: results ?? this.results,
        loading: loading ?? this.loading,
        pageCount: pageCount ?? this.pageCount,
        totalResultCount: totalResultCount,
        displayName: displayName ?? this.displayName,
        nodeId: nodeId ?? this.nodeId,
        tracked: tracked,
        dataType: dataType ?? this.dataType,
        serverId: serverId ?? this.serverId,
        finished: finished ?? this.finished,
      );

  List<Filter> getFilters() {
    return [
      if (nodeId.isNotEmpty)
        Filter(key: 'identifier', operator: FilterType.LIKE, value: nodeId),
      if (nodeId.isNotEmpty)
        Filter(key: 'identifier', operator: FilterType.LIKE, value: nodeId),
      if (displayName.isNotEmpty)
        Filter(
            key: 'display_name', operator: FilterType.LIKE, value: displayName),
      if (dataType != DataType.none)
        Filter(
          key: 'data_type',
          operator: FilterType.EQ,
          value: dataType.toString().split('.').last,
        ),
      if (serverId.isNotEmpty)
        Filter(key: 'server_id', operator: FilterType.EQ, value: '$serverId'),
      if (tracked != null)
        Filter(
            key: 'tracked',
            operator: FilterType.EQ,
            value: tracked! ? '1' : '0'),
    ];
  }
}
