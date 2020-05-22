import 'dart:async';

import 'package:dividegame/screens/game/GameScreeenController.dart';
import 'package:flutter/material.dart';

import 'game/pause_dialog.dart';

class TimerWidget extends StatefulWidget {
  bool restart;
  final GameScreenController gameScreenController;

  TimerWidget(this.restart, this.gameScreenController);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  DateTime startTime;
  bool pause;
  ValueNotifier<String> timeToShow;
  Duration currentDuration;

  @override
  void initState() {
    super.initState();
    pause = false;
    startTime = DateTime.now();
    timeToShow = ValueNotifier('');
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) getTimeInString();
    });
  }

  String getTimeInString() {
    if (widget.restart) {
      currentDuration = Duration();
      startTime = null;
      if (pause) {
        timeToShow.value = '0:00:00';
        pause = false;
      }
      return timeToShow.value;
    }
    if (!pause) {
      if (startTime == null) startTime = DateTime.now();
      DateTime currentTime = DateTime.now();
      Duration diff = currentTime.difference(startTime);
      timeToShow.value = diff.toStringForTimer();
      currentDuration = diff;
    }
    return timeToShow.value;
  }

  void toggle() async {
    if (pause) {
      if (currentDuration != null) {
        DateTime currentTime = DateTime.now();
        startTime = currentTime.subtract(currentDuration);
        pause = false;
      }
    } else {
      await showDialog(
          context: context,
          builder: (context) => Dialog(
                child: PauseDialog(widget.gameScreenController.scaffoldKey),
              ));
      pause = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ValueListenableBuilder<String>(
            valueListenable: timeToShow,
            builder: (context, value, child) {
              return Text(value,
                  style: TextStyle(color: Colors.white70, fontSize: 32));
            },
          ),
          const SizedBox(
            width: 32,
          ),
          GestureDetector(
            onTap: () {
              toggle();
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 4)),
              padding: EdgeInsets.all(8),
              child: Icon(
                pause ? Icons.play_arrow : Icons.pause,
                size: 24,
                color: Colors.white70,
              ),
            ),
          )
        ],
      ),
    );
  }
}

extension DurationString on Duration {
  String toStringForTimer() {
    return this.toString().split('.')[0];
  }
}
