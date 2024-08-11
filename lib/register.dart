import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vase/common/toast.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  String _username = '';
  String _phone = '';
  String _password = '';
  String _password2 = '';
  Map<String, dynamic>? user;

  void _register() async {
    if (_password != _password2) {
      showToast(context, '两次密码不一致');
      return;
    } else {
      Dio dio = Dio();
      Response response =
          await dio.post('http://123.60.145.37:5000/user/register', data: {
        'phone': _phone,
        'password': _password,
        'username': _username,
      });
      var data = json.decode(response.toString());
      if (data['code'] == 'SUCCESS') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('注册成功'),
              content: const Text('请登录'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      } else {
        showToast(context, '用户名或手机号已存在');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 105),
              child: const Image(
                  image: AssetImage('images/icon.png'),
                  width: 100,
                  height: 100),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Text(
                '注册',
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
                  labelText: '用户名',
                ),
                onChanged: (value) => _username = value,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: '手机号',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _phone = value,
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
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: '再次输入密码',
                ),
                obscureText: true,
                onChanged: (value) => _password2 = value,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 160,
              height: 40,
              child: ElevatedButton(
                onPressed: _register,
                child: const Text('注册',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 20,
              ),
              width: 160,
              height: 40,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('已经有账号？登陆',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
