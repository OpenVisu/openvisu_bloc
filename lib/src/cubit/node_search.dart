import 'package:openvisu_bloc/openvisu_bloc.dart';
import 'package:openvisu_repository/openvisu_repository.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Function uolwq = const DeepCollectionEquality.unordered().equals;

/// Node Cubit which handles the list of nodes searchable by the user
class NodeSearchCubit extends Cubit<NodeSearchState> {
  final NodeRepository nodeRepository;

  /// Initiating the Cubit with an empty list
  NodeSearchCubit({
    required final this.nodeRepository,
  }) : super(NodeSearchState()) {
    loadData();
  }

  /// The number of items collected in each iteration
  final int pageSize = 30;

  /// Error indicator
  String error = '';

  void setDisplayName(final String displayName) {
    setSearch(
      displayName: displayName,
      tracked: state.tracked,
    );
  }

  void setNodeId(final String nodeId) {
    setSearch(
      nodeId: nodeId,
      tracked: state.tracked,
    );
  }

  void setTracked(final bool? tracked) {
    setSearch(
      tracked: tracked,
    );
  }

  void setServerId(final Pk<Server>? serverId) {
    setSearch(
      serverId: serverId,
      tracked: state.tracked,
    );
  }

  void setDataType(final DataType dataType) {
    setSearch(
      dataType: dataType,
      tracked: state.tracked,
    );
  }

  void setSearch({
    final String? displayName,
    final String? nodeId,
    required final bool? tracked,
    final Pk<Server>? serverId,
    final DataType? dataType,
  }) {
    emit(state.copyWith(
      totalResultCount: null,
      displayName: displayName,
      nodeId: nodeId,
      tracked: tracked,
      dataType: dataType,
      serverId: serverId,
    ));
    localSearch();
    reset();
    loadData();
  }

  void localSearch() {
    final List<Node> filteredLists = state.results.where((Node node) {
      if (state.displayName.isNotEmpty) {
        if (!node.displayName
            .toLowerCase()
            .contains(state.displayName.toLowerCase())) {
          return false;
        }
      }
      if (state.nodeId.isNotEmpty) {
        if (!node.nodeId.toLowerCase().contains(state.nodeId.toLowerCase())) {
          return false;
        }
      }
      if (state.tracked != null) {
        if (node.tracked != state.tracked) {
          return false;
        }
      }
      if (state.dataType != DataType.none) {
        if (node.datatype != state.dataType) {
          return false;
        }
      }
      if (state.serverId.isNotEmpty) {
        if (node.serverId != state.serverId) {
          return false;
        }
      }
      return true;
    }).toList();

    emit(state.copyWith(
      results: filteredLists,
      totalResultCount: null,
      tracked: state.tracked,
    ));
  }

  /// reset the load index
  void reset() {
    emit(state.copyWith(
      totalResultCount: null,
      finished: false,
      pageCount: 0,
      tracked: state.tracked,
    ));
  }

  ///  When infiniteScroll is called, the current state
  ///  of the cubit is accessed via `state` and
  ///  a new `state` is emitted via `emit`.
  Future<void> loadData() async {
    if (state.finished) {
      return;
    }

    if (!state.loading) {
      emit(state.copyWith(
        totalResultCount: state.totalResultCount,
        tracked: state.tracked,
        loading: true,
      ));
    }

    // store query parameters
    final List<Filter> filters = state.getFilters();
    final int pageCount = state.pageCount;

    List<Node> nodes = await nodeRepository
        .paginated(
      pageCount: state.pageCount,
      pageSize: pageSize,
      filter: filters,
    )
        .onError((error, stackTrace) {
      this.error = error.toString(); // TODO error is never reset
      return [];
    });

    // filters no longer match query => abort
    if (pageCount != state.pageCount || !uolwq(filters, state.getFilters())) {
      return;
    }

    emit(state.copyWith(
      results: state.pageCount == 0 ? nodes : [...state.results, ...nodes],
      pageCount: state.pageCount + 1,
      totalResultCount: state.totalResultCount,
      displayName: state.displayName,
      nodeId: state.nodeId,
      tracked: state.tracked,
      serverId: state.serverId,
      loading: false,
      finished: nodes.length < pageSize,
    ));
  }
}
