import 'package:doublegame/screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(DoubleGameApp());

class DoubleGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      navigatorKey: Get.key,
      title: 'Double',
      home: SplashScreen(),
    );
  }
}