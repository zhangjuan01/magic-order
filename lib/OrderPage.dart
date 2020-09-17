import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:convert';

Dio dio = Dio();

class OrderPage extends StatefulWidget {
  OrderPage({Key key, this.orderData, this.id}) : super(key: key);
  final dynamic orderData;
  final int id;

  @override
  _OrderPageState createState() => _OrderPageState();
}

class OrderData {
  final int id;
  final String demandTypeStr;
  final String demandDetail;
  final String address;
  final String memo;
  final double distance;
  final double price;
  final int needDadaCount;
  final String orderTime;

  const OrderData({
    this.id,
    this.demandTypeStr,
    this.demandDetail,
    this.address,
    this.memo,
    this.distance,
    this.price,
    this.needDadaCount,
    this.orderTime,
  });

  factory OrderData.fromMap(Map<String, dynamic> json) {
    var _skillResult = '[]';
    if (json == null) return null;
    return OrderData(
      id: json["id"] as int,
      demandTypeStr: json["demandTypeStr"] as String,
      demandDetail: json['demandDetail'] as String,
      address: json['address'] as String,
      memo: json['memo'] as String,
      distance: json['distance'] as double,
      price: json['price'] as double,
      needDadaCount: json['needDadaCount'] as int,
      orderTime: json['orderTime'] as String,
    );
  }
}

class _OrderPageState extends State<OrderPage> {
  String orderDatas = '';
  String icons = '';
  dynamic id = 1;
  bool isBusy = false;

  GlobalKey _formKey = new GlobalKey<FormState>();

  final TextEditingController _controller = new TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // 绑定骑士ID
  void _saveKnightId(value) async {
    print('value => $value');
    setState(() {
      id = value;
    });
  }

// 弹出对话框
  Future<bool> showDeleteConfirmDialog1() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("骑士ID"),
          content: TextField(
            controller: _controller,
            decoration: new InputDecoration(
              hintText: 'Type something',
            ),
            onChanged: _saveKnightId,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("删除"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  // void addSocketConnect() async {
  //   var socket = await WebSocket.connect('http://dftask-x5frwn.ndev.imdada.cn/hack/pushOrderToTransporter?dadaId=$id}');
  //   socket.listen((event) {
  //     print("Server: $event");
  //   });
  //   print('socket => $socket');
  //   socket.close();
  // }
  void _toggleBusy() async {
    const period = const Duration(seconds: 10);
    Timer.periodic(period, (timer) async {
      loadOrderList();
      if (!isBusy) {
        timer.cancel();
      }
    });
    setState(() {
      isBusy = !isBusy;
    });
  }
  // 列表数据页
  void loadOrderList() async {
    Response response;
    response = await dio.get(
        "http://dftask-x5frwn.ndev.imdada.cn/hack/pushOrderToTransporter?dadaId=$id");
    setState(() {
      orderDatas = convert.jsonEncode(response.data['content']);
    });
  }

  // 骑士接单
  void _acceptOrder(id) async {
    Response response;
    response = await dio
        .put("http://dftask-x5frwn.ndev.imdada.cn/hack/acceptOrder/$id");
    loadOrderList();
  }

  Future<String> _getOrderData() async {
    return orderDatas;
  }

  @override
  Widget build(BuildContext context) {
    print('id => $id');
    if (orderDatas.isNotEmpty) {
      List<OrderData> datas = ((json.decode(orderDatas) ?? []) as List)
          .map<OrderData>(
            (dayMap) => OrderData.fromMap(dayMap),
          )
          .toList();
    }
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            leading:
                Icon(Icons.person_outline, size: 30.0, color: Colors.black),
            title: new Center(
              child: OutlineButton.icon(
                icon: new Icon(Icons.sentiment_very_satisfied),
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                ),
                label: Text("${isBusy ? '开工' : '休息'}"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                onPressed: _toggleBusy,
              ),
            ),
            actions: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 10.0),
                child: new Icon(Icons.notifications_none,
                    size: 28.0, color: Colors.black),
              )
            ],
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image(
                  image: AssetImage("images/logo.png"),
                  height: 84.0,
                ),
                Container(
                  // height: 300,
                  child: FutureBuilder(
                    future: _getOrderData(),
                    initialData: '',
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data != '') {
                        List<OrderData> orders =
                            ((json.decode(snapshot.data) ?? []) as List)
                                .map<OrderData>(
                                  (dayMap) => OrderData.fromMap(dayMap),
                                )
                                .toList();
                        return Column(
                            children: orders
                                .map<Widget>((item) => Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Form(
                                              // key: _formKey, //设置globalKey，用于后面获取FormState
                                              autovalidate: true, //开启自动校验
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        top: 10.0,
                                                        left: 10.0),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '¥${item.price}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${item.orderTime}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        top: 10.0),
                                                    child: Divider(
                                                        height: 1.0,
                                                        indent: 0,
                                                        color: Colors.grey),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        left: 10.0),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              '内容：${item.demandTypeStr}'),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${item.distance}公里',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 14.0),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        left: 10.0),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              '详情：${item.demandDetail}'),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child:
                                                              Text('均价：1万以上'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        left: 10.0),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                              '地址：${item.address}'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 20.0,
                                                        left: 10.0),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                              '备注：${item.memo}',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: RaisedButton(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    15.0),
                                                            child: Text("接单"),
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            textColor:
                                                                Colors.white,
                                                            onPressed: () {
                                                              _acceptOrder(
                                                                  item.id);
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList());
                      }
                      return Text(
                        '暂无订单',
                        style: TextStyle(),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
              child: Container(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    highlightColor: Colors.white,
                    child: Text('接单设置'),
                    onPressed: () async {
                      //弹出对话框并等待其关闭
                      bool delete = await showDeleteConfirmDialog1();
                      if (delete == null) {
                        print("取消删除");
                      } else {
                        print("已确认删除");
                        //... 删除文件
                      }
                    },
                  ),
                  OutlineButton(
                      padding: const EdgeInsets.only(left: 60.0, right: 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        "刷新列表",
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {},
                      borderSide: BorderSide(width: 1.0, color: Colors.green)),
                  FlatButton(
                    highlightColor: Colors.white,
                    child: Text('管理技能'),
                    onPressed: () {
                      Navigator.pushNamed(context, 'skill_edit',
                          arguments: {"id": id});
                    },
                  ),
                ],
              ),
            ),
          )),
          // floatingActionButton:
          // FloatingActionButton(child: Icon(Icons.add), onPressed: () {}),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ));
    // TODO: implement build
    throw UnimplementedError();
  }
}
