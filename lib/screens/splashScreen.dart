import 'package:dividegame/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1))
        .then((value) => Get.off(HomePageScreen()));
    return Material(
      child: Center(
        child: Text('DIVIDE \nThe Game'),
      ),
    );
  }
}
