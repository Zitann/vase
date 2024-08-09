import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'home.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  String _phone = '123';
  String _password = 'admin';
  Map<String, dynamic>? user;
  String? token;

  void _login() async {
    Dio dio = Dio();
    Response response =
        await dio.post('http://123.60.145.37:5000/user/login', data: {
      'phone': _phone,
      'password': _password,
    });
    var data = json.decode(response.toString());
    if (data['code'] == 'SUCCESS') {
      token = data['data']['token'];
      user = data['data']['user'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user', const JsonEncoder().convert(user));
      prefs.setString('token', token!);
      Navigator.replace(context,
          oldRoute: ModalRoute.of(context)!,
          newRoute: MaterialPageRoute(
              builder: (context) =>
                  Home(title: '植物列表', user: user!, token: token!)));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('登陆失败'),
            content: const Text('用户名或密码错误'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 150),
              child: const Image(
                  image: AssetImage('images/icon.png'),
                  width: 100,
                  height: 100),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Text(
                '登陆',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.none),
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: '手机号',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _phone = value,
                controller: TextEditingController(text: '123'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: '密码',
                ),
                obscureText: true,
                onChanged: (value) => _password = value,
                controller: TextEditingController(text: 'admin'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 160,
              height: 40,
              child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('登陆',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none))),
            ),
            Container(
              width: 160,
              height: 40,
              margin: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Register()));
                },
                child: const Text('注册',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
