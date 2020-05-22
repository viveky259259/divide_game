import 'package:dividegame/model/dragNumbers.dart';
import 'package:flutter/material.dart';

import '../numberDelegate.dart';

class DragWidget extends StatefulWidget {
  final DragNumbers dragNumbers;
  final int x, y;
  List<List<int>> datas;

  DragWidget(this.dragNumbers, this.x, this.y, this.datas);

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
    List<int> list = List();

    for (int i = 0; i < widget.datas.length; i++) {
      for (int j = 0; j < widget.datas[i].length; j++) {
        list.add(widget.datas[i][j]);
      }
    }
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
