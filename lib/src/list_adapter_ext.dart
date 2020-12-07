import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '_widget_utils.dart';
import 'list_adapter.dart';

///
/// 提供了一些扩张Adapter类
///

///
/// 支持通过ViewType注册buildItem的Adapter
///
///
class ViewTypeAdapter<T> extends Adapter<T> {
  Map<int, Widget Function(BuildContext context, int index)> handlers = {};

  void addViewType(int viewType,
      Widget Function(BuildContext context, int index) viewTypeBuilder) {
    handlers[viewType] = viewTypeBuilder;
  }

  void addDefaultViewType(
      Widget Function(BuildContext context, int index) viewTypeBuilder) {
    handlers[0] = viewTypeBuilder;
  }

  int itemViewType(int index) {
    return 0;
  }

  @override
  Widget buildItemWidget(BuildContext context, int index) {
    final viewType = itemViewType(index);
    final builder = handlers[viewType];
    if (builder != null) {
      return builder(context, index);
    }

    // 当没有匹配的ViewType时，返回一个大小为0的界面
    return SizedBox(height: 0, width: 0);
  }
}

///
///
/// 下面是一组带分页功能的ListView和Adapter
///
///

/// 分页组件的状态
enum PagingState { INIT, HAS_MORE, PAGE_LOAD_FAILED, NO_MORE }

///
/// 带分页功能的Adapter的控制器
///
class PagingAdapterController {
  Widget _loadingMoreWidget;
  Widget _loadingErrorWidget;
  Widget _noMoreWidget;
  Widget _hasMoreWidget; // 一占位，

  PagingState _pagingState = PagingState.INIT;

  /// 当前是否正在加载
  bool _loading = false;
  bool _pagingEnable = false;

  /// 当没有下一页的时候是否显示到底了
  bool _isShowNoMore = true;

  /// 加载更多监听
  void Function() onLoadMore;

  final Adapter adapter;

  PagingAdapterController(this.adapter) {
    _loadingMoreWidget = _buildLoadingUI();
    _loadingErrorWidget = _buildLoadErrorUI(() {
      // 失败点击重试
      _pagingState = PagingState.HAS_MORE;
      _triggerLoadMore();
    });
    _noMoreWidget = _buildNoMoreUI();
    _hasMoreWidget = _buildHasMoreUI();
  }

  Widget _buildHasMoreUI() {
    return SizedBox(
      height: 50,
    );
  }

  _triggerLoadMore() {
    print("triggerLoadMore:$_loading, $_pagingEnable, $_pagingState");
    if (_loading || !_pagingEnable || _pagingState != PagingState.HAS_MORE) {
      return;
    }

    _loading = true;
    if (onLoadMore != null) {
      onLoadMore();
    }
    _pagingState = PagingState.HAS_MORE;
    _notifyStateChange();
  }

  ///
  /// 当分页数据拉取完成之后调用该方法通知分页组件
  ///
  /// @param isPageLoadSuc 数据是否拉成功
  /// @param hasMore 是否有下一页
  /// @param enablePaging 是否要开启分页功能
  ///
  void loadFinish(
      [bool isPageLoadSuc, bool hasMore = true, bool enablePaging = true]) {
    _loading = false;

    if (enablePaging) {
      if (!isPageLoadSuc) {
        _pagingState = PagingState.PAGE_LOAD_FAILED;
      } else if (!hasMore) {
        _pagingState = PagingState.NO_MORE;
      } else {
        _pagingState = PagingState.HAS_MORE;
      }
    } else {
      _pagingState = PagingState.INIT;
    }

    print(
        "loadingFinish:$isPageLoadSuc, hasMore:$hasMore, enable:$enablePaging, sate:$_pagingState");

    _pagingEnable = enablePaging;

    _notifyStateChange();
  }

  void _notifyStateChange() {
    switch (_pagingState) {
      case PagingState.HAS_MORE:
        adapter.removeFooter(_loadingErrorWidget, isNotify: false);
        adapter.removeFooter(_noMoreWidget, isNotify: false);
        if (_loading) {
          adapter.removeFooter(_hasMoreWidget);
          adapter.addFooter(_loadingMoreWidget,
              canDuplicateAdd: false, isNotify: false);
        } else {
          adapter.removeFooter(_loadingMoreWidget);
          adapter.addFooter(_hasMoreWidget,
              canDuplicateAdd: false, isNotify: false);
        }

        break;
      case PagingState.PAGE_LOAD_FAILED:
        adapter.addFooter(_loadingErrorWidget,
            canDuplicateAdd: false, isNotify: false);
        adapter.removeFooter(_noMoreWidget, isNotify: false);
        adapter.removeFooter(_loadingMoreWidget, isNotify: false);
        adapter.removeFooter(_hasMoreWidget, isNotify: false);
        break;
      case PagingState.NO_MORE:
        adapter.removeFooter(_loadingErrorWidget, isNotify: false);
        if (_isShowNoMore) {
          adapter.addFooter(_noMoreWidget,
              canDuplicateAdd: false, isNotify: false);
        }
        adapter.removeFooter(_loadingMoreWidget, isNotify: false);
        adapter.removeFooter(_hasMoreWidget, isNotify: false);
        break;
      case PagingState.INIT:
        adapter.removeFooter(_loadingErrorWidget, isNotify: false);
        adapter.removeFooter(_noMoreWidget, isNotify: false);
        adapter.removeFooter(_loadingMoreWidget, isNotify: false);
        adapter.removeFooter(_hasMoreWidget, isNotify: false);
        break;
    }
    adapter.notifyDataSetChange();
  }

  static Widget _buildLoadingUI() {
    return quickContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          quickContainer(
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
              width: 15,
              height: 15),
          quickTextWithContainer("正在加载中...",
              textSize: 12, color: Colors.black12, marginLeft: 10)
        ],
      ),
      height: 50,
    );
  }

  static Widget _buildLoadErrorUI(void onTryAgain()) {
    return GestureDetector(
      child: quickContainer(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              quickTextWithContainer("加载失败",
                  textSize: 12, color: Colors.black12, marginLeft: 10)
            ],
          ),
          height: 50),
      onTap: onTryAgain, // 点击重新加载一次
    );
  }

  static Widget _buildNoMoreUI() {
    return quickContainer(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            quickTextWithContainer("到底啦～",
                textSize: 12, color: Colors.black12, marginLeft: 10)
          ],
        ),
        height: 50);
  }
}

/// 抽象一个PagingAdapter的接口
abstract class LoadMoreAdapter {
  void triggerLoadMore();
}

///
/// 带分页功能的普通Adapter
///
abstract class PagingAdapter<T> extends Adapter<T> implements LoadMoreAdapter {
  /// 加载更多监听

  PagingAdapter({List<T> data, bool isShowNoMore = true}): super(data: data) {
    _pagingAdapterController = PagingAdapterController(this);
    _pagingAdapterController._isShowNoMore = isShowNoMore;
  }

  set onLoadMore(void Function() onLoadMore) {
    _pagingAdapterController.onLoadMore = onLoadMore;
  }

  PagingAdapterController _pagingAdapterController;

  triggerLoadMore() {
    _pagingAdapterController._triggerLoadMore();
  }

  ///
  /// 当分页数据拉取完成之后调用该方法通知分页组件
  ///
  /// @param isPageLoadSuc 数据是否拉成功
  /// @param hasMore 是否有下一页
  /// @param enablePaging 是否要开启分页功能
  ///
  void loadFinish(
      [bool isPageLoadSuc, bool hasMore = true, bool enablePaging = true]) {
    _pagingAdapterController.loadFinish(isPageLoadSuc, hasMore, enablePaging);
  }
}

///
/// 一个带分页功能的ListView
///
class PagingAdapterListView extends AdapterListView {
  // NotificationListenerCallback<T> onNotification;

  final bool isListenScroll;

  PagingAdapterListView(Adapter adapter,
      {Axis scrollDirection = Axis.vertical,
      bool reverse = false,
      ScrollController controller,
      bool primary,
      ScrollPhysics physics,
      bool shrinkWrap = false,
      EdgeInsetsGeometry padding,
      bool addAutomaticKeepAlives = true,
      bool addRepaintBoundaries = true,
      bool addSemanticIndexes = true,
      double cacheExtent,
      int semanticChildCount,
      DragStartBehavior dragStartBehavior = DragStartBehavior.start,
      IndexedWidgetBuilder separatorBuilder,

        this.isListenScroll = false
      })
      : super(adapter,
            scrollDirection: scrollDirection,
            reverse: reverse,
            controller: controller,
            primary: primary,
            physics: physics,
            shrinkWrap: shrinkWrap,
            padding: padding,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            cacheExtent: cacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            separatorBuilder: separatorBuilder) {
    //ignore
  }

  @override
  State<StatefulWidget> createState() {
    print("AdapterList createState");
    return PagingAdapterListViewState(adapter as LoadMoreAdapter);
  }
}

/// 带分页功能ListView的State
class PagingAdapterListViewState extends AdapterListViewState {
  LoadMoreAdapter _adapter;

  LoadMoreAdapter get loadMoreAdapter => _adapter;

  bool isScrolling = false;

  PagingAdapterListViewState(LoadMoreAdapter adapter)
      : _adapter = adapter,
        super(adapter as Adapter);

  // 是否监听用户的滑动
  bool isListenScroll() {
    final wt = widget;
    if (wt is PagingAdapterListView) {
      return wt.isListenScroll;
    }
    return false;
  }

  Widget buildContent() {
    return NotificationListener ( //<ScrollEndNotification>(
      onNotification: (notification) {


        if (notification is ScrollStartNotification) { // 滑动开始

          if (isListenScroll()) {
            isScrolling = true;
            setState(() {

            });
          }
        } else if (notification is ScrollEndNotification) { // 滑动结束
          if (isListenScroll()) {
            isScrolling = false;
            setState(() {

            });
          }

          print(
              "notifi:$notification, depth:${notification.depth}, matrix:${notification.metrics}");

          // 滑动到了底部，加载更多数据
          if (notification.depth == 0 &&
              notification.metrics.axisDirection == AxisDirection.down &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 40) {
            _adapter.triggerLoadMore();
          }
        }

        return false;
      },
      child: buildListView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildContent();
  }
}

///
/// 带分页功能的普通Adapter
///
class PagingMergeAdapter extends MergeAdapter implements LoadMoreAdapter {
  /// 加载更多监听

  set onLoadMore(void Function() onLoadMore) {
    _pagingAdapterController.onLoadMore = onLoadMore;
  }

  PagingAdapterController _pagingAdapterController;

  PagingMergeAdapter({bool isShowNoMore = true}) {
    _pagingAdapterController = PagingAdapterController(this);
    _pagingAdapterController._isShowNoMore = isShowNoMore;
  }

  triggerLoadMore() {
    _pagingAdapterController._triggerLoadMore();
  }

  ///
  /// 当分页数据拉取完成之后调用该方法通知分页组件
  ///
  /// @param isPageLoadSuc 数据是否拉成功
  /// @param hasMore 是否有下一页
  /// @param enablePaging 是否要开启分页功能
  ///
  void loadFinish(
      [bool isPageLoadSuc, bool hasMore = true, bool enablePaging = true]) {
    _pagingAdapterController.loadFinish(isPageLoadSuc, hasMore, enablePaging);
  }
}
//
// ///
// /// 一个带分页功能支持MergeAdapter的 ListView
// ///
// class PagingMergeAdapterListView extends PagingAdapterListView {
//   PagingMergeAdapterListView(PagingMergeAdapter adapter,
//       {Axis scrollDirection = Axis.vertical,
//       bool reverse = false,
//       ScrollController controller,
//       bool primary,
//       ScrollPhysics physics,
//       bool shrinkWrap = false,
//       EdgeInsetsGeometry padding,
//       bool addAutomaticKeepAlives = true,
//       bool addRepaintBoundaries = true,
//       bool addSemanticIndexes = true,
//       double cacheExtent,
//       int semanticChildCount,
//       DragStartBehavior dragStartBehavior = DragStartBehavior.start,
//       IndexedWidgetBuilder separatorBuilder})
//       : super(adapter,
//             scrollDirection: scrollDirection,
//             reverse: reverse,
//             controller: controller,
//             primary: primary,
//             physics: physics,
//             shrinkWrap: shrinkWrap,
//             padding: padding,
//             addAutomaticKeepAlives: addAutomaticKeepAlives,
//             addRepaintBoundaries: addRepaintBoundaries,
//             addSemanticIndexes: addSemanticIndexes,
//             cacheExtent: cacheExtent,
//             semanticChildCount: semanticChildCount,
//             dragStartBehavior: dragStartBehavior,
//             separatorBuilder: separatorBuilder) {
//     //ignore
//   }
//
//   @override
//   State<StatefulWidget> createState() {
//     print("AdapterList createState");
//     return _PagingMergeAdapterListView(adapter as LoadMoreAdapter);
//   }
// }
//
// class _PagingMergeAdapterListView extends PagingAdapterListViewState {
//   _PagingMergeAdapterListView(LoadMoreAdapter adapter) : super(adapter);
//
//   @override
//   PagingMergeAdapterListView get widget {
//     return super.widget;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return super.build(context);
//   }
// }
