import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'game/gameScreen.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  AssetsAudioPlayer assetsAudioPlayer;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey();
    assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      playBGSound();
    });
  }

  void playBGSound() {
    assetsAudioPlayer.open(Audio("asset/sounds/airtone_-_nightWalk.mp3"),
        autoStart: true, respectSilentMode: false);
    assetsAudioPlayer.playlistAudioFinished.listen((event) {
      assetsAudioPlayer.open(Audio("asset/sounds/airtone_-_nightWalk.mp3"),
          autoStart: true, respectSilentMode: false);
    });
  }

  void stopBGSound() {
    assetsAudioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Expanded(
            flex: 3,
            child: Center(child: Image.asset('asset/images/divide_logo.png')),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            'Divide',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 64),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 64),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    color: Colors.green,
                    child: Text(
                      ' 3 x 3',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    onPressed: () async {
                      stopBGSound();
                      await Get.to(GameScreen(1, 3, 3));
                      playBGSound();
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 64),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    color: Colors.green,
                    child: Text(
                      ' 4 x 4',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    onPressed: () async {
                      stopBGSound();
                      await Get.to(GameScreen(1, 4, 4));
                      playBGSound();
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    color: Colors.green,
                    child: Text(
                      'Time Limit',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    onPressed: () async {
                      stopBGSound();
                      await Get.to(GameScreen(2, 3, 3));
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
