import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan/scan.dart';
import 'package:vase/common/toast.dart';

class Addplant extends StatefulWidget {
  const Addplant({super.key, required this.token});
  final String token;
  @override
  _AddplantState createState() => _AddplantState();
}

class _AddplantState extends State<Addplant> {
  String name = '';
  String description = '';
  String plantId = '';
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  List<BluetoothService> _services = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  String ssid = '';
  String password = '';
  ScanController controller = ScanController();
  String qrcode = '';
  bool isScan = false;
  bool wifi = false;
  String mac = '';
  bool isUnit = false;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      print(_scanResults);
      if (mounted) {
        setState(() {});
      }
    }, onError: (error) {
      print('Scan Error:$error');
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });
    FlutterBluePlus.turnOn();

    plantId = guid();
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    FlutterBluePlus.stopScan();
    controller.pause();
    super.dispose();
  }

  String guid() {
    // 生成uuid xxxxxxx-xxxxxxx
    var s = '';
    if (isUnit) {
      s += '0';
    } else {
      // 不能是0
      s += (Random().nextInt(15) + 1).toRadixString(16);
    }
    for (var i = 0; i < 6; i++) {
      s += (Random().nextInt(16).toRadixString(16));
    }
    s += '-';
    for (var i = 0; i < 7; i++) {
      s += (Random().nextInt(16).toRadixString(16));
    }
    return s;
  }

  Uint8List encode(String s) {
    List<int> list = utf8.encode(s);
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }

  void connectDevice(BluetoothDevice device) async {
    try {
      print(device.remoteId.str);
      BluetoothCharacteristic c1;
      BluetoothCharacteristic c2;
      await device.connect();
      _services = await device.discoverServices();
      c1 = _services[2].characteristics[0];
      c2 = _services[2].characteristics[1];
      Uint8List message = encode(plantId);
      await c2.write(message,
          withoutResponse: c2.properties.writeWithoutResponse);
      sleep(const Duration(seconds: 1));
      message = encode('$ssid,$password');
      await c1.write(message,
          withoutResponse: c1.properties.writeWithoutResponse);
      showToast(context, '配网成功');
    } catch (e) {
      showToast(context, '$e');
      print(e);
    }
  }

  void addPlant() async {
    if (name == '' || description == '') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('添加失败'),
              content: const Text('请填写完整信息'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            );
          });
      return;
    }

    if (ssid == '' || password == '') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('添加失败'),
              content: const Text('请先选择设备'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            );
          });
      return;
    }

    if (ssid == '' || password == '') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('添加失败'),
              content: const Text('请填写Wifi信息'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            );
          });
      return;
    }

    // 添加植物
    Dio dio = Dio();
    Response response = await dio.post('http://123.60.145.37:5000/plant/info',
        data: {
          'name': name,
          'description': description,
          'image': 'default.jpg',
          'id': plantId
        },
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}));
    var data = response.data;
    if (data['code'] == 'SUCCESS') {
      showToast(context, '添加植物成功');
      Navigator.pop(context);
    } else {
      showToast(context, '添加植物失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('添加植物'),
        ),
        body: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFDADFF0),
                        offset: Offset(0, 5),
                        blurRadius: 10)
                  ],
                  image: DecorationImage(
                      image: NetworkImage(
                          'http://123.60.145.37:5000/plant/show/zijinghua.jpg'),
                      fit: BoxFit.cover),
                ),
                height: 200,
                child: Row(
                  children: [Container(
                    margin: EdgeInsets.only(top: 140,left: 20),
                    width: 80,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F3FA),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(value: isUnit, onChanged: (value) {
                          isUnit = value!;
                          plantId = guid();
                          setState(() {});
                        }),
                        const Text('集群')
                      ],
                    ),
                  ),]
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFF2F3FA),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFDADFF0),
                        offset: Offset(0, 5),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: '植物名称',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: '植物描述',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onChanged: (value) => description = value,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFF2F3FA),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFDADFF0),
                        offset: Offset(0, 5),
                        blurRadius: 10)
                  ],
                ),
                child: wifi
                    ? Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Wifi名称',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onChanged: (value) => ssid = value,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Wifi密码',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onChanged: (value) => password = value,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    wifi = false;
                                    isScan = false;
                                    _scanResults = [];
                                    setState(() {});
                                  },
                                  child: const Text('取消')),
                              ElevatedButton(
                                  onPressed: () {
                                    wifi = false;
                                    isScan = false;
                                    _scanResults = [];
                                    setState(() {});
                                    connectDevice(BluetoothDevice(
                                        remoteId: DeviceIdentifier(mac)));
                                  },
                                  child: const Text('确认')),
                            ],
                          )
                        ],
                      )
                    : isScan
                        ? ScanView(
                            controller: controller,
                            scanAreaScale: .7,
                            scanLineColor: Colors.blue.shade400,
                            onCapture: (data) {
                              wifi = true;
                              isScan = false;
                              setState(() {});
                              controller.pause();
                              data = data.replaceAll(RegExp(r'MAC '), '');
                              print('dc-----data$data');
                              mac = data;
                            },
                          )
                        : ListView.builder(
                            itemCount: _scanResults.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color(0xFFFFFFFF),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xFFDADFF0),
                                        offset: Offset(0, 5),
                                        blurRadius: 10)
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _scanResults[index]
                                              .device
                                              .platformName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            '(${_scanResults[index].device.remoteId})')
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        wifi = true;
                                        isScan = false;
                                        setState(() {});
                                        mac = _scanResults[index]
                                            .device
                                            .remoteId
                                            .str;
                                      },
                                      child: const Text('连接'),
                                    )
                                  ],
                                ),
                              );
                            }),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isScan
                          ? FloatingActionButton(
                              onPressed: () {
                                wifi = false;
                                isScan = false;
                                _scanResults = [];
                                controller.pause();
                                setState(() {});
                              },
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.qr_code_scanner,
                                  color: Colors.white),
                            )
                          : FloatingActionButton(
                              onPressed: () async {
                                await Permission.camera.request();
                                wifi = false;
                                isScan = true;
                                _scanResults = [];
                                controller.resume();
                                setState(() {});
                              },
                              child: const Icon(Icons.qr_code_scanner),
                            ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: addPlant,
                            child: const Text('添加植物',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none))),
                      ),
                      FlutterBluePlus.isScanningNow
                          ? FloatingActionButton(
                              onPressed: () {
                                wifi = false;
                                isScan = false;
                                controller.pause();
                                setState(() {});
                                FlutterBluePlus.stopScan();
                              },
                              backgroundColor: Colors.red,
                              child: const Text(
                                "停止",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : FloatingActionButton(
                              onPressed: () async {
                                wifi = false;
                                isScan = false;
                                controller.pause();
                                setState(() {});
                                try {
                                  _systemDevices =
                                      await FlutterBluePlus.systemDevices;
                                  print('dc-----_systemDevices$_systemDevices');
                                } catch (e) {
                                  print("Stop Scan Error:$e");
                                }
                                try {
                                  int divisor = Platform.isAndroid ? 8 : 1;
                                  await FlutterBluePlus.startScan(
                                      timeout: const Duration(seconds: 15),
                                      continuousUpdates: true,
                                      continuousDivisor: divisor);
                                } catch (e) {
                                  print("Stop jzt Error:$e");
                                }
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: const Text("扫描"),
                            ),
                    ],
                  ))
            ],
          )),
        ));
  }
}
