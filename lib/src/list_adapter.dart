




import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';




abstract class StateAware {
  void changeState();
  BuildContext get context;
  Widget get widget;
}

///
/// 模仿Android，提供一个Adapter给用户使用
///
abstract class Adapter<T> {

  // 支持添加Header和Footer
  List<Widget> _headers = [];
  List<Widget> _footers = [];

  // Adapter关联的数据
  List<T> mData = [];
  List<T> get data =>mData;

  // Adapter关联的state对象
  StateAware state;

  /// 获取关联的state对象
  StateType getState<StateType extends StateAware>() {
     return state;
  }

  void Function() _dataSetChange;

  set dataSetChange(Function value) {
    _dataSetChange = value;
  }

  /// 构造器
  Adapter({List<T> data}) {
    if (data != null) {
      mData = data;
    }
  }

  /// 关联的Context对象
  BuildContext get context {
    return state.context;    
  }

  /// 是否包含了该Header
  bool isHeaderContains(Widget header) {
    return _headers.contains(header);
  }

  /// 是否包含该Footer
  bool isFooterContains(Widget footer) {
    return _footers.contains(footer);
  }

  /// 添加一个头部
  void addHeader(Widget header, {bool canDuplicateAdd = true, bool isNotify = true}) {
    if (!canDuplicateAdd && isHeaderContains(header)) {
      return ;
    }

    _headers.add(header);

    if (isNotify) {
      notifyDataSetChange();
    }
  }

  /// 删除header
  void removeHeader(Widget header, {bool isNotify = true}) {
    while(_headers.remove(header)) {}

    if (isNotify) {
      notifyDataSetChange();
    }
  }

  /// 初始化状态
  /// Adapter是一个有状态的对象，它的生命周期一般跟着包含它的State一起走
  void onHostStateInitState() {}

  /// 状态被销毁
  /// Adapter是一个有状态的对象，它的生命周期一般跟着包含它的State一起走
  void onHostStateDispose() {

  }

  /// 添加一个Footer
  void addFooter(Widget footer,  {bool canDuplicateAdd = true, bool isNotify = true}) {
    if (!canDuplicateAdd && isFooterContains(footer)) {
      return;
    }
    _footers.add(footer);

    if (isNotify) {
      notifyDataSetChange();
    }
  }

  /// 删除Footer
  void removeFooter(Widget footer, {bool isNotify = true}) {
    while(_footers.remove(footer)) {}

    if (isNotify) {
      notifyDataSetChange();
    }
  }

  /// 添加多条数据
  void appendAll(List<T> data) {
    mData.addAll(data);
    notifyDataSetChange();
  }

  /// 添加单条数据
  void append(T data) {
    mData.add(data);
    notifyDataSetChange();
  }

  /// 清空数据
  void clearData({bool isNotify = false}) {
    mData.clear();
    if (isNotify) {
      notifyDataSetChange();
    }
  }

  /// 更新数据
  void setData(List<T> data) {
    mData.clear();
    mData.addAll(data);
    notifyDataSetChange();
  }


  /// 包括header和footer的条目数
  int itemCountInner() {
    return itemCount() + _headers.length + _footers.length;
  }

  /// ListView的条目，不包括header和footer
  int itemCount() {
    return mData.length;
  }

  ///
  T itemAt(int index) {
    return mData[index];
  }

  /// 通知数据更新了
  notifyDataSetChange() {
    state?.changeState();
    _dataSetChange?.call();
  }

  // void changeState() {
  //   try {
  //     if (state.mounted) {
  //       state.setState(() {
  //
  //       });
  //     }
  //   } catch (e) {
  //     // TODO 有时间看下这个错误是怎么报出来的
  //     print("changeState:$e");
  //     // ingore
  //   }
  // }

  /// 内部的buildItem方法
  Widget buildItemInner(BuildContext context, int index) {
    final dataLength = itemCount();
    if (index < _headers.length) {
      return _headers[index];
    } else if (index >= _headers.length + dataLength) {
      return _footers[index - (dataLength + _headers.length) ];
    } else {
      // 这里会把index
      return buildItemWidget(context, index - _headers.length);
    }
  }

  ///
  /// 构建ListView的item
  /// 子类要重写的buildItem方法
  Widget buildItemWidget(BuildContext context, int index);
}




///
/// 可以拼接多个Adapter
///
class MergeAdapter extends Adapter {

  List<Adapter> mAdapters = [];

  @override
  int itemCount() {
    int count = 0;
    mAdapters.forEach((adapter) {
      count += adapter.itemCountInner();
    });
    return count;
  }


  /// 不支持itemAt
  @override
  itemAt(int index) {
    throw Exception("MergeAdapter unsupport this action");
  }

  ///
  /// 添加一个子Adapter
  ///
  void addAdapter(Adapter adapter) {
    mAdapters.add(adapter);
    adapter.dataSetChange = ()=> notifyDataSetChange();
    notifyDataSetChange();
  }

  ///
  /// 删除一个子Adapter
  ///
  removeAdapter(Adapter adapter) {
    mAdapters.remove(adapter);
    notifyDataSetChange();
  }

  ///
  /// 是否包含某个子Adapter
  ///
  bool contains(Adapter adapter) {
    return mAdapters.contains(adapter);
  }


  @override
  Widget buildItemWidget(BuildContext context, int index) {
    for (int i=0; i<mAdapters.length; i++) {
      final Adapter ad = mAdapters[i];

      // 逐步减去头部的adapter的个数
      int subCount = ad.itemCountInner();
      if (index < subCount) {
        return ad.buildItemInner(context, index);
      }
      index -= subCount;
      index = max(index, 0);
    }
    return null;
  }
}



///
/// 一个模仿Android ListView的控件
///
/// 这个控件支持设置一个 Adapter对象来设置显示内容
///
class AdapterListView extends StatefulWidget {

  final Adapter adapter;

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  final IndexedWidgetBuilder separatorBuilder;

  AdapterListView(this.adapter,
      {
        this.scrollDirection = Axis.vertical,
        this.reverse = false,
        this.controller,
        this.primary,
        this.physics,
        this.shrinkWrap = false,
        this.padding,
        this.addAutomaticKeepAlives = true,
        this.addRepaintBoundaries = true,
        this.addSemanticIndexes = true,
        this.cacheExtent,
        this.semanticChildCount,
        this.dragStartBehavior = DragStartBehavior.start,
        this.separatorBuilder
      })
  {
    //ignore
  }

  @override
  State<StatefulWidget> createState() {
    print("AdapterList createState");
    return AdapterListViewState(adapter);
  }

  @override
  StatefulElement createElement() {
    print("AdapterList createElement");
    return super.createElement();
  }
}



class AdapterListViewState<T extends AdapterListView> extends State<T> implements StateAware {

  Adapter _adapter;
  Adapter get adapter => _adapter;

  AdapterListViewState(this._adapter) {
    _adapter.state = this;
  }

  @override
  void changeState() {
    try {
      if (mounted) {
        setState(() {

        });
      }
    } catch (e) {
      // TODO 有时间看下这个错误是怎么报出来的
      print("changeState:$e");
      // ingore
    }
  }

  @override
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();
    _adapter.onHostStateInitState();
  }

  @override
  void dispose() {
    super.dispose();
    _adapter.onHostStateDispose();
  }



  // void didUpdateWidget(AdapterListView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  // }


  Widget buildListView() {

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,

        itemBuilder: (context, index) {
          return _adapter.buildItemInner(context, index);
        },
        itemCount: _adapter.itemCountInner(),

        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        dragStartBehavior: widget.dragStartBehavior,
        separatorBuilder: widget.separatorBuilder,
      );
    } else {
      return ListView.builder(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,

        itemBuilder: (context, index) {
          return _adapter.buildItemInner(context, index);
        },
        itemCount: _adapter.itemCountInner(),

        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return buildListView();
  }
}



