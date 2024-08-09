import 'package:flutter/material.dart';
import 'Tabs/account.dart';
import 'Tabs/plants.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title, required this.user , required this.token});
  final String title;
  final Map<String, dynamic> user;
  final String token;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int index = 0;
  String title = '植物列表';

  static List<Widget> _widgetOptions = <Widget>[];
  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      Plants(token: widget.token),
      Account(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( 
          title: Text(title),
          centerTitle: true,
        ),
        body:Center(
          child: _widgetOptions.elementAt(index),
        ), 
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: '植物',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '我的',
            ),
          ],
          currentIndex: index,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: (int i) {
            setState(() {
              index = i;
              title = i == 0 ? '植物列表' : '账户信息';
            });
          },
        )
    );
  }
}
