import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'common/toast.dart';

class Details extends StatefulWidget {
  const Details(
      {super.key,
      required this.name,
      required this.description,
      required this.bgImage,
      required this.token,
      required this.id});
  final String name;
  final String description;
  final String bgImage;
  final String token;
  final String id;

  @override
  State<Details> createState() => DetailsState();
}

class DetailsState extends State<Details> {
  String name = '';
  String description = '';
  String imageUrl = '';
  dynamic historyData = [];
  List humidity = [];
  List temperature = [];
  List luminance = [];
  bool edit = false;
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    description = widget.description;
    imageUrl = 'http://123.60.145.37:5000/plant/show/${widget.bgImage}';
    getHistory();
  }

  void getHistory() async {
    // 获取植物历史数据
    Dio dio = Dio();
    Response response = await dio.get(
        'http://123.60.145.37:5000/history/data?id=${widget.id}',
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        }));
    var data = response.data;
    if (data['code'] == 'SUCCESS') {
      setState(() {
        historyData = data['data'];
        humidity = historyData.map((e) => e['humidity']).toList();
        temperature = historyData.map((e) => e['temperature']).toList();
        luminance = historyData.map((e) => e['luminance']).toList();
      });
    } else {
      showToast(context, '获取历史数据失败');
    }
  }

  void sendCommand(String str) async {
    // 发送控制命令
    Dio dio = Dio();
    Response response = await dio.post('http://123.60.145.37:5000/podcast/send',
        data: {
          'plant_id': widget.id,
          'command': str,
        },
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        }));
    var data = response.data;
    if (data['code'] == 'SUCCESS') {
      showToast(context, '发送成功');
    } else {
      showToast(context, '发送失败');
    }
  }

  void updatePlant() async {
    // 更新植物信息
    Dio dio = Dio();
    Response response = await dio.put('http://123.60.145.37:5000/plant/info',
        data: {
          'id': widget.id,
          'name': name,
          'description': description,
          'image': widget.bgImage
        },
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        }));
    var data = response.data;
    if (data['code'] == 'SUCCESS') {
      showToast(context, '更新成功');
    } else {
      showToast(context, '更新失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFFDADFF0),
                      offset: Offset(0, 5),
                      blurRadius: 10)
                ],
                image: DecorationImage(
                    image: imageUrl ==
                            'http://123.60.145.37:5000/plant/show/default.jpg'
                        ? const AssetImage('images/flower.png')
                        : NetworkImage(imageUrl),
                    fit: BoxFit.cover),
              ),
              height: 150,
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
                  edit
                      ? TextField(
                          decoration: const InputDecoration(
                            labelText: '植物名称',
                            hintText: '请输入植物名称',
                          ),
                          controller: TextEditingController(text: name),
                          onChanged: (value) => name = value,
                        )
                      : Text(
                          name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                  edit
                      ? TextField(
                          decoration: const InputDecoration(
                            labelText: '植物描述',
                            hintText: '请输入植物描述',
                          ),
                          controller:
                              TextEditingController(text: widget.description),
                          onChanged: (value) => description = value,
                        )
                      : Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Text(
                            description,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                        ),
                ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 120,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (edit) {
                                  updatePlant();
                                }
                                edit = !edit;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF409EFF),
                            ),
                            child: edit
                                ? const Text(
                                    '保存',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : const Text(
                                    '编辑',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          )),
                      SizedBox(
                          width: 120,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              sendCommand('switch');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF409EFF),
                            ),
                            child: const Text(
                              '切换屏幕',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                            width: 120,
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.wb_sunny,
                                    color: isOn ? Colors.blue : Colors.grey),
                                Switch(
                                    value: isOn,
                                    onChanged: (value) {
                                      setState(() {
                                        isOn = value;
                                        isOn
                                            ? sendCommand('light-on')
                                            : sendCommand('light-off');
                                      });
                                    })
                              ],
                            )),
                        SizedBox(
                          width: 120,
                          height: 30,
                          child: ElevatedButton(
                              onPressed: () {
                                sendCommand('water');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF409EFF),
                              ),
                              child: const Text(
                                '浇水',
                                style: TextStyle(color: Colors.white),
                              )),
                        )
                      ],
                    ),
                  )
                ],
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        '实时数据',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.blue,
                        onPressed: getHistory,
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DataCard(
                            unit: ' ℃',
                            value: temperature.isEmpty
                                ? 0
                                : temperature[temperature.length - 1],
                            title: '温度',
                            icon: Icons.thermostat),
                        DataCard(
                            unit: ' %',
                            value: humidity.isEmpty
                                ? 0
                                : humidity[humidity.length - 1],
                            title: '湿度',
                            icon: Icons.opacity),
                        DataCard(
                            unit: ' Lux',
                            value: luminance.isEmpty
                                ? 0
                                : luminance[luminance.length - 1],
                            title: '光照',
                            icon: Icons.wb_sunny),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        '历史数据',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.blue,
                        onPressed: getHistory,
                      )
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 250,
                      child: historyData.isEmpty
                          ? const Text('暂无历史数据',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  decoration: TextDecoration.none))
                          : // 用fl_chart展示三个数据的折线图，用swiper实现左右滑动
                          Swiper.children(
                              children: [
                                Column(
                                  children: [
                                    const Text('温度(℃)',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            decoration: TextDecoration.none)),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, top: 10, right: 10),
                                      height: 200,
                                      child: LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: temperature
                                                  .asMap()
                                                  .entries
                                                  .map((e) => FlSpot(
                                                      e.key.toDouble(),
                                                      e.value.toDouble()))
                                                  .toList(),
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 4,
                                              isStrokeCapRound: true,
                                            )
                                          ],
                                          minY: 0,
                                          maxY: temperature
                                                  .reduce((value, element) =>
                                                      value > element
                                                          ? value
                                                          : element)
                                                  .toDouble() +
                                              10,
                                          titlesData: const FlTitlesData(
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false))),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('湿度(%)',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            decoration: TextDecoration.none)),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, top: 10, right: 10),
                                      height: 200,
                                      child: LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: humidity
                                                  .asMap()
                                                  .entries
                                                  .map((e) => FlSpot(
                                                      e.key.toDouble(),
                                                      e.value.toDouble()))
                                                  .toList(),
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 4,
                                              isStrokeCapRound: true,
                                            )
                                          ],
                                          minY: 0,
                                          maxY: humidity
                                                  .reduce((value, element) =>
                                                      value > element
                                                          ? value
                                                          : element)
                                                  .toDouble() +
                                              10,
                                          titlesData: const FlTitlesData(
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false))),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('光照(Lux)',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            decoration: TextDecoration.none)),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, top: 10, right: 10),
                                      height: 200,
                                      child: LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: luminance
                                                  .asMap()
                                                  .entries
                                                  .map((e) => FlSpot(
                                                      e.key.toDouble(),
                                                      e.value.toDouble()))
                                                  .toList(),
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 4,
                                              isStrokeCapRound: true,
                                            )
                                          ],
                                          minY: 0,
                                          maxY: luminance
                                                  .reduce((value, element) =>
                                                      value > element
                                                          ? value
                                                          : element)
                                                  .toDouble() +
                                              10,
                                          titlesData: const FlTitlesData(
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false))),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ))
                ],
              ),
            ),
          ],
        )));
  }
}

class DataCard extends StatelessWidget {
  const DataCard(
      {super.key,
      required this.unit,
      required this.value,
      required this.title,
      required this.icon});
  final String unit;
  final double value;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(value.toString(),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none)),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      decoration: TextDecoration.none)),
            ],
          ),
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      decoration: TextDecoration.none)),
              Icon(icon, color: Colors.blue),
            ],
          )
        ],
      ),
    );
  }
}
