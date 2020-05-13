import 'package:dividegame/model/dragNumbers.dart';
import 'package:flutter/material.dart';

import '../numberDelegate.dart';

class DragWidget extends StatefulWidget {
  final DragNumbers dragNumbers;
  final int x, y;

  DragWidget(this.dragNumbers, this.x, this.y);

  @override
  _DragWidgetState createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  int maxNum;

  @override
  void initState() {
    super.initState();
    maxNum = NumberDelegate.getMaxNumConsideration(widget.x, widget.y);
  }

  void getRandomValue() {
    NumberDelegate.generateRandomNumber(widget.dragNumbers, maxNum);
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: widget.dragNumbers.currentNum,
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
              widget.dragNumbers.currentNum.toString(),
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
            widget.dragNumbers.currentNum.toString(),
            style: TextStyle(color: Colors.white70, fontSize: 42),
          )),
        ),
      ),
    );
  }
}
