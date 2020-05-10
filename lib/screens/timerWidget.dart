import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  bool restart;

  TimerWidget(this.restart);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  DateTime startTime;
  bool pause;
  String timeToShow;
  Duration currentDuration;

  @override
  void initState() {
    super.initState();
    pause = false;
    startTime = DateTime.now();
    timeToShow = '';
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  String getTimeInString() {
    print(widget.restart);
    if (widget.restart) {
      currentDuration = Duration();
      startTime = null;
      if (pause) {
        timeToShow = '0:00:00';
        pause = false;
      }
      return timeToShow;
    }
    if (!pause) {
      if (startTime == null) startTime = DateTime.now();
      DateTime currentTime = DateTime.now();
      Duration diff = currentTime.difference(startTime);
      timeToShow = diff.toStringForTimer();
      currentDuration = diff;
    }
    return timeToShow;
  }

  toggle() {
    if (pause) {
      if (currentDuration != null) {
        DateTime currentTime = DateTime.now();
        startTime = currentTime.subtract(currentDuration);
        pause = false;
      }
    } else
      pause = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            getTimeInString(),
            style: TextStyle(color: Colors.white70, fontSize: 32),
          ),
          SizedBox(
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
