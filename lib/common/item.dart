import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../details.dart';
import 'toast.dart';

class Item extends StatelessWidget {
  const Item(
      {super.key,
      required this.name,
      required this.description,
      required this.bgImage,
      required this.id,
      required this.token,
      required this.context});
  final String name;
  final String description;
  final String bgImage;
  final String id;
  final String token;
  final BuildContext context;

  void deletePlant() async {
    // 删除植物
    Dio dio = Dio();
    Response response = await dio.delete('http://123.60.145.37:5000/plant/info?id=$id',
    options: Options(headers: {'Authorization': 'Bearer $token','Content-Type': 'application/json'}));
    if (response.data['code'] == 'SUCCESS') {
      showToast(context, '删除植物成功');
    }else{
      showToast(context, '删除植物失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => Details(name: name, description: description, bgImage: bgImage, token: token, id: id))),
      onLongPress: () => {
        // 删除弹窗
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('删除'),
                content: const Text('确定删除吗？'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: (){
                      deletePlant();
                      Navigator.pop(context);
                    },
                    child: const Text('确定'),
                  ),
                ],
              );
            })
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xFFF2F3FA),
          boxShadow: [
            BoxShadow(
                color: Color(0xFFDADFF0), offset: Offset(0, 5), blurRadius: 10)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  decoration: TextDecoration.none),
            ),
            Text(
              description,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}
