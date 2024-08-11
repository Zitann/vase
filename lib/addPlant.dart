import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_ble/universal_ble.dart';
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
  dynamic devices = [];
  String ssid = '';
  String password = '';
  final String serviceId = 'EFCDAB90-7856-3412-EFCD-AB9078563412';
  final String characteristicId = '0000FF01-0000-1000-8000-00805F9B34FB';
  final String characteristicId2 = '0000FF02-0000-1000-8000-00805F9B34FB';

  void requirePermission() async {
    var isLocationGranted = await Permission.locationWhenInUse.request();
    print('checkBlePermissions, isLocationGranted=$isLocationGranted');

    var isBleGranted = await Permission.bluetooth.request();
    print('checkBlePermissions, isBleGranted=$isBleGranted');

    var isBleScanGranted = await Permission.bluetoothScan.request();
    print('checkBlePermissions, isBleScanGranted=$isBleScanGranted');
    //
    var isBleConnectGranted = await Permission.bluetoothConnect.request();
    print('checkBlePermissions, isBleConnectGranted=$isBleConnectGranted');
    //
    var isBleAdvertiseGranted = await Permission.bluetoothAdvertise.request();
    print('checkBlePermissions, isBleAdvertiseGranted=$isBleAdvertiseGranted');

    checkAndOpenBluetooth();
  }

  @override
  void initState() {
    super.initState();
    requirePermission();
    plantId = guid();
  }

  String guid() {
    // 生成uuid xxxxxxx-xxxxxxx
    String s = '';
    for (var i = 0; i < 7; i++) {
      s += ((1 + Random().nextDouble()) * 0x10000)
          .toInt()
          .toRadixString(16)
          .substring(1);
    }
    s += '-';
    for (var i = 0; i < 7; i++) {
      s += ((1 + Random().nextDouble()) * 0x10000)
          .toInt()
          .toRadixString(16)
          .substring(1);
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

  void checkAndOpenBluetooth() async {
    AvailabilityState state =
        await UniversalBle.getBluetoothAvailabilityState();
    if (state == AvailabilityState.poweredOn) {
      UniversalBle.onScanResult = (bleDevice) {
        setState(() {
          devices.add(bleDevice);
        });
      };
      UniversalBle.startScan();
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('蓝牙未开启'),
              content: const Text('请开启蓝牙后再试'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            );
          });
    }
  }

  void connectDevice(String deviceId) async {
    try {
      UniversalBle.stopScan();
      await UniversalBle.connect(deviceId);
      Uint8List message = encode('$ssid,$password');
      UniversalBle.writeValue(deviceId, serviceId, characteristicId, message,
          BleOutputProperty.withoutResponse);
      sleep(const Duration(seconds: 1));
      message = encode(plantId);
      UniversalBle.writeValue(deviceId, serviceId, characteristicId2, message,
          BleOutputProperty.withoutResponse);
    } catch (e) {
      showToast(context, '连接设备失败$e');
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

    if (devices.length == 0) {
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
                margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
                child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color(0xFFFFFFFF),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFFDADFF0),
                                offset: Offset(0, 5),
                                blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(devices[index].name ?? '未知设备'),
                            ElevatedButton(
                              onPressed: () {
                                //弹出Wifi输入框
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('请输入Wifi信息'),
                                      content: SizedBox(
                                        height: 110,
                                        child: Column(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Wifi名称',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                              ),
                                              onChanged: (value) =>
                                                  ssid = value,
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Wifi密码',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                              ),
                                              onChanged: (value) =>
                                                  password = value,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            connectDevice(
                                                devices[index].deviceId);
                                          },
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text('选择'),
                            )
                          ],
                        ),
                      );
                    }),
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
              )
            ],
          )),
        ));
  }
}
