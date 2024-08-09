import 'dart:convert';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // 设置背景颜色
        // 设置文字样式
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child:Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 150),
          child: const Image(
              image: AssetImage('images/icon.png'), width: 100, height: 100),
        ),
        Container(
          margin: const EdgeInsets.only(top: 250),
          child: const Text(
            '云 瓶',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.none),
            textWidthBasis: TextWidthBasis.longestLine,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: const Text(
            'Smart Vase',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
        ),
        FutureBuilder(
          future: () async {
            final prefs = await SharedPreferences.getInstance();
            String user = prefs.getString('user') ?? '';
            String token = prefs.getString('token') ?? '';
            Map<String, dynamic> userMap = {};
            Future.delayed(
                const Duration(seconds: 1),
                () => {
                      if (user.isNotEmpty)
                        {
                          userMap = const JsonDecoder().convert(user),
                          Navigator.replace(context,
                              oldRoute: ModalRoute.of(context)!,
                              newRoute: MaterialPageRoute(
                                  builder: (context) => Home(
                                      title: '植物列表', user: userMap,token: token,)))
                        }
                      else
                        {
                          Navigator.replace(context,
                              oldRoute: ModalRoute.of(context)!,
                              newRoute: MaterialPageRoute(
                                  builder: (context) => const Login()))
                        }
                    });
          }(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return const SizedBox.shrink();
          },
        )
      ],
    ));
  }
}
