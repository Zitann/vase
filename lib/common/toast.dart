import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


FToast fToast = FToast();
void showToast(BuildContext context, String msg) {
  fToast.init(context);
  fToast.showToast(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 97, 97, 97),
      ),
      child: Text(msg, style: const TextStyle(color: Colors.white)),
    ),
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}
