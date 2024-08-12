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
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  String ssid = '';
  String password = '';
  final String serviceId = 'efcdab90-7856-3412-efcd-ab9078563412';
  final String characteristicId = '0000ff01-0000-1000-8000-00805f9b34fb';
  final String characteristicId2 = '0000ff02-0000-1000-8000-00805f9b34fb';
  ScanController controller = ScanController();
  String qrcode = '';
  bool isScan = false;
  bool wifi = false;
  String mac = '';

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
    for (var i = 0; i < 7; i++) {
      s += (Random().nextInt(16).toRadixString(16));
    }
    s += '-';
    for (var i = 0; i < 7; i++) {
      s += (Random().nextInt(16).toRadixString(16));
    }
    return s;
  }

  Uint8List encode(String s) {
    var encodedString = utf8.encode(s);
    var encodedLength = encodedString.length;
    var data = ByteData(encodedLength + 4);
    data.setUint32(0, encodedLength, Endian.big);
    var bytes = data.buffer.asUint8List();
    bytes.setRange(4, encodedLength + 4, encodedString);
    return bytes;
  }

  void connectDevice(BluetoothDevice device) async {
    try {
      print(device.remoteId.str);
      BluetoothCharacteristic c1 = BluetoothCharacteristic(
          remoteId: device.remoteId,
          serviceUuid: Guid(serviceId),
          characteristicUuid: Guid(characteristicId));
      BluetoothCharacteristic c2 = BluetoothCharacteristic(
          remoteId: device.remoteId,
          serviceUuid: Guid(serviceId),
          characteristicUuid: Guid(characteristicId2));
      await device.connect();
      // _services = await device.discoverServices();
      // for (var service in _services) {
      //   if (service.serviceUuid.str == serviceId) {
      //     for (var c in service.characteristics) {
      //       if (c.characteristicUuid.str == characteristicId) {
      //         c1 = c;
      //       }
      //       if (c.characteristicUuid.str == characteristicId2) {
      //         c2 = c;
      //       }
      //     }
      //   }
      // }
      Uint8List message = encode('$ssid,$password');
      await c1.write(message,
          withoutResponse: c1.properties.writeWithoutResponse);
      print("Write: Success");
      sleep(const Duration(seconds: 1));
      message = encode(plantId);
      await c2.write(message,
          withoutResponse: c2.properties.writeWithoutResponse);
      print("Write: Success2");
    } catch (e) {
      // showToast(context, '连接设备失败$e');
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

    if (_scanResults.length == 0) {
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
// custom scan area, if set to 1.0, will scan full area
                            scanAreaScale: .7,
                            scanLineColor: Colors.green.shade400,
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
