import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vase/common/toast.dart';
import '../addPlant.dart';
import '../common/item.dart';

class Plants extends StatefulWidget {
  const Plants({super.key, required this.token});
  final String token;

  @override
  State<Plants> createState() => PlantsState();
}

class PlantsState extends State<Plants> {
  dynamic plants = [];
  String token = '';
  
  Future<void> _getPlants() async {
    // 获取植物列表
    Dio dio = Dio();
    Response response = await dio.get('http://123.60.145.37:5000/plant/list', options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}));
    if (response.data['code'] == 'SUCCESS') {
      var data = response.data['data'];
      setState(() {
        // 更新植物列表
        plants = data;
      });
    }else{
      showToast(context, '获取植物列表失败');
    }
  }

  
  void addPlant() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Addplant(token: widget.token)));
  }

  @override
  void initState() {
    super.initState();
    _getPlants();
  }

  @override
  void didUpdateWidget(covariant Plants oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
          onRefresh: _getPlants,
          child: ListView.builder(
            itemCount: plants.length,
            itemBuilder: (BuildContext context, int index) {
              return Item(
                name: plants[index]['name'],
                description: plants[index]['description'],
                bgImage: plants[index]['image'],
                id: plants[index]['id'],
                token: widget.token,
                context: context,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addPlant,
          child: const Icon(Icons.add),
        )
    );
  }
}
