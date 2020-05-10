import 'dart:math';

import 'package:flutter/material.dart';

class DragWidget extends StatefulWidget {
  @override
  _DragWidgetState createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  int currentValue;

  @override
  void initState() {
    super.initState();
    getRandomValue();
  }

  void getRandomValue() {
    currentValue = Random().nextInt(8) + 2;
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: currentValue,
      onDragCompleted: () {
        getRandomValue();
        setState(() {});
      },
      feedback: Material(
        color: Color.fromRGBO(101, 213, 181, 0.8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Center(
          child: Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
                color: Color.fromRGBO(101, 213, 181, 0.8),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Center(
                child: Text(
              currentValue.toString(),
              style: TextStyle(color: Colors.white70, fontSize: 42),
            )),
          ),
        ),
      ),
      childWhenDragging: Center(
        child: Container(),
      ),
      child: Center(
        child: Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
              color: Color.fromRGBO(101, 213, 181, 0.8),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Center(
              child: Text(
            currentValue.toString(),
            style: TextStyle(color: Colors.white70, fontSize: 42),
          )),
        ),
      ),
    );
  }
}
