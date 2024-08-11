import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';

class Account extends StatefulWidget {
  const Account({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<Account> createState() => AccountState();
}

class AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 58),
              child: const Image(
                  image: AssetImage('images/icon.png'),
                  width: 100,
                  height: 100),
            ),
            Container(
                margin: const EdgeInsets.only(top: 50, left: 50, right: 50),
                padding: const EdgeInsets.all(15),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '用户名',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          decoration: TextDecoration.none),
                    ),
                    Text(
                      widget.user['username'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          decoration: TextDecoration.none),
                    ),
                  ],
                )),
            Container(
                margin: const EdgeInsets.only(top: 20, left: 50, right: 50),
                padding: const EdgeInsets.all(15),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '手机号',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          decoration: TextDecoration.none),
                    ),
                    Text(
                      widget.user['phone'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          decoration: TextDecoration.none),
                    ),
                  ],
                )),
            Container(
                margin: const EdgeInsets.only(top: 50),
                width: 160,
                height: 40,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFDADFF0),
                        offset: Offset(0, 5),
                        blurRadius: 10)
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.remove('token');
                    prefs.remove('user');
                    Navigator.replace(context,
                        oldRoute: ModalRoute.of(context)!,
                        newRoute: MaterialPageRoute(
                            builder: (context) => const Login()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('退出登录',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          decoration: TextDecoration.none)),
                )),
          ],
        ),
      ),
    );
  }
}
