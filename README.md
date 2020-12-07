# adapter_listview

一个类似Android ListView Adapter的高可用性和扩展性的组件

## Getting Started

引入组件：

```
  adapter_listview:
    git: https://github.com/xiaofanqingzjj/adapter_listview
```


## 基本用法

和Android中的Adapter使用方式一样：


```
/// Adapter的基本用法
class BaseListAdapter<String> extends Adapter {
  BaseListAdapter(List data) : super(data: data);

  @override
  Widget buildItemWidget(BuildContext context, int index) {
    final item = itemAt(index);
    return ListTile(
      leading: Icon(
          Icons.location_city_outlined
      ),
      title: Text(item),
    );
  }
}

class _TestBaseAdapterListView extends State<TestBaseAdapterListView> {
  List<String> data = <String>["Beijing", "Hongkong", "Shanghai"];
  Adapter adapter;

  @override
  void initState() {
    super.initState();
    adapter = BaseListAdapter(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("基本用法"),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {
            // 更新数据
            data.add("Yue yang");
            // 通知列表更新
            adapter.notifyDataSetChange();
          }),

          IconButton(icon: Icon(Icons.add), onPressed: () {
            data.insert(0, "Chong qing");
            adapter.notifyDataSetChange();
          }),
        ],
      ),
      body: Container(child: AdapterListView(adapter)),
    );
  }
}

```


## 给Adapter添加Head和Footer


```
   adapter.addHeader(Container(
              color: Colors.blue,
              height: 80,
              child: Center(
                child: Text("Header"),
              ),
            ));

   adapter.addFooter(Container(
             color: Colors.yellow,
             height: 40,
             child: Center(
               child: Text("Footer"),
             ),
           ));

```

## MergeAdapter

```
class _TestMergeAdapterListViewState extends State<TestMergeAdapterListView> {
  Adapter adapter1;
  Adapter adapter2;
  Adapter adapter3;
  Adapter adapter4;

  MergeAdapter mergeAdapter = MergeAdapter();
  @override
  void initState() {
    super.initState();
    adapter1 = ListAdapter("Adapter1", Colors.red);
    adapter2 = ListAdapter("Adapter2", Colors.blue);
    adapter3 = ListAdapter("Adapter3", Colors.yellow);
    adapter4 = ListAdapter("Adapter4", Colors.green);

    mergeAdapter.addAdapter(adapter1);
    mergeAdapter.addAdapter(adapter2);
    mergeAdapter.addAdapter(adapter3);
    mergeAdapter.addAdapter(adapter4);
  }

  Widget testHeader = Container(
    color: Colors.blue,
    height: 80,
    child: Center(
      child: Text("Header"),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MergeAdapter"),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {
            adapter1.addHeader(testHeader);
          }),

          IconButton(icon: Icon(Icons.add), onPressed: () {
            adapter2.addHeader(testHeader);
          }),
        ],
      ),
      body: Container(child: AdapterListView(mergeAdapter)),
    );
  }
}


class ListAdapter extends Adapter {
  String name;
  Color bgColor;

  ListAdapter([this.name, this.bgColor]);

  @override
  int itemCount() {
    return 10;
  }

  @override
  Widget buildItemWidget(BuildContext context, int index) {
    return ListTile(
      title: Text(name),
      tileColor: bgColor,
    );
  }

}

```

## PagingAdapter



