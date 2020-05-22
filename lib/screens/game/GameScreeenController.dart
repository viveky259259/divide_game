import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameScreenController {
  GlobalKey<ScaffoldState> scaffoldKey;
  Duration currentGameDuration;

  GameScreenController() {
    this.scaffoldKey = GlobalKey();
  }
}
