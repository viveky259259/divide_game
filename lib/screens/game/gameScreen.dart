import 'package:doublegame/model/dragNumbers.dart';
import 'package:doublegame/screens/numberDelegate.dart';
import 'package:doublegame/screens/timerWidget.dart';
import 'package:flutter/material.dart';

import 'dragWidget.dart';

class GameScreen extends StatefulWidget {
  final int type;
  final int x;
  final int y;

  GameScreen(this.type, this.x, this.y);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class Pairs {
  final int a;
  final int b;
  final int i1, i2;
  final int j1, j2;
  int ans;

  Pairs(this.a, this.b, this.i1, this.j1, this.i2, this.j2);

  int calculate() {
    if (a % b == 0 || b % a == 0) {
      if (a == b) {
        ans = 1;
        return 1;
      }

      if (a > b)
        ans = a ~/ b;
      else {
        ans = (b / a).toInt();
        ans = ans * -1;
      }
      print(ans);
      return ans;
    } else
      return -1;
  }
}

class _GameScreenState extends State<GameScreen> {
  bool isSuccessful = false;
  int keep = -1;
  int score = 0;
  DragNumbers dragNumbers;
  List<List<int>> datas;
  bool restart;

  void initState() {
    super.initState();
    restart = false;
    datas = new List.generate(widget.x, (_) => new List(widget.y));
    dragNumbers = DragNumbers();
    NumberDelegate.generateRandomNumber(dragNumbers);
    updateData();
  }

  void updateData() {
    for (int i = 0; i < widget.x; i++) {
      for (int j = 0; j < widget.y; j++) {
        datas[i][j] = -1;
      }
    }
    score = 0;
  }

  void startCalculation() {
    List<Pairs> pairs = List();
    //check horizontal
    for (int i = 0; i < widget.x; i++) {
      for (int k = 0; k < widget.y - 1; k++) {
        int a = datas[i][k];
        int b = datas[i][k + 1];
        Pairs first;
        if (a * b > 0 && (a != -1 && b != -1))
          first = Pairs(a, b, i, k, i, k + 1);

        if (first != null) pairs.add(first);
      }
    }
    //check vertical
    for (int i = 0; i < widget.x - 1; i++) {
      for (int k = 0; k < widget.y; k++) {
        int a = datas[i][k];
        int b = datas[i + 1][k];
        Pairs first;
        if (a * b > 0 && (a != -1 && b != -1))
          first = Pairs(a, b, i, k, i + 1, k);

        if (first != null) pairs.add(first);
      }
    }
    bool recheck = false;
    pairs.forEach((e) {
      print('${e.a} , ${e.b}');
      e.calculate();
      if (e.ans == null) return;
      if (e.ans == 1) {
        datas[e.i1][e.j1] = -1;
        datas[e.i2][e.j2] = -1;
        int score = e.a * e.b;
        this.score = this.score + (score > 0 ? score : score * -1);
      } else if (e.ans != -1) {
        if (e.ans < 0) {
          datas[e.i1][e.j1] = -1;
          datas[e.i2][e.j2] = e.ans * -1;
          recheck = true;
          int score = e.a * e.b;
          this.score = this.score + (score > 0 ? score : score * -1);
        } else if (e.ans > 0) {
          datas[e.i2][e.j2] = -1;
          datas[e.i1][e.j1] = e.ans;
          recheck = true;
          int score = e.a * e.b;
          this.score = this.score + (score > 0 ? score : score * -1);
        }
      }
    });
    setState(() {});
    if (recheck) {
      startCalculation();
      return;
    }
    if (!recheck) {
      checkIfGameEnds();
    }
  }

  checkIfGameEnds() async {
    bool gameEnds = true;
    for (int i = 0; i < widget.x - 1; i++) {
      if (gameEnds)
        for (int k = 0; k < widget.y; k++) {
          if (datas[i][k] == -1) {
            gameEnds = false;
            break;
          }
        }
      else
        break;
    }
    if (gameEnds) {
      setState(() {
        restart = true;
      });
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Game Ends'),
                content: Text('$score Scored'),
              ));
      setState(() {
        updateData();
        restart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TimerWidget(restart),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.poll,
                  color: Colors.white70,
                  size: 48,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  '$score',
                  style: TextStyle(color: Colors.white70, fontSize: 32),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      restart = true;
                    });
                    updateData();
                    Future.delayed(Duration(milliseconds: 16))
                        .then((value) => setState(() {
                              restart = false;
                            }));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 4)),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.restore,
                      size: 32,
                      color: Colors.white70,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.custom(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.x,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                      mainAxisSpacing: 8,
                    ),
                    childrenDelegate:
                        SliverChildBuilderDelegate((context, index) {
                      bool isAccepted = false;
                      int acceptedData;
                      int i = index ~/ widget.x;
                      int j = index % widget.y;
                      return DragTarget(
                        onLeave: (a) {
                          print(11);
                        },
                        builder:
                            (context, List<int> candidateData, rejectedData) {
                          if (datas[i][j] != -1)
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(101, 213, 181, 0.8),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Center(
                                    child: Text(
                                  datas[i][j].toString(),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 42),
                                )),
                              ),
                            );
                          else if (isAccepted)
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(101, 213, 181, 0.8),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Center(
                                    child: Text(
                                  datas[i][j].toString(),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 42),
                                )),
                              ),
                            );
                          else
                            return Container(
                              decoration: BoxDecoration(
                                  color: candidateData.length > 0
                                      ? Color.fromRGBO(101, 213, 181, 0.8)
                                      : Colors.white38,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Center(
                                  child: Text(
                                candidateData.length > 0
                                    ? candidateData[0].toString()
                                    : '',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 42),
                              )),
                            );
                        },
                        onWillAccept: (data) {
                          return datas[i][j] == -1;
                        },
                        onAccept: (data) {
                          isAccepted = true;
                          acceptedData = data;
                          print(data);
                          datas[i][j] = data;
                          startCalculation();
                        },
                      );
                    }, childCount: widget.y * widget.x)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Text(
                  'Keep',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.13,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(101, 213, 181, 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Center(
                            child: Text(
                          dragNumbers.nextToNext.toString(),
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                        )),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(101, 213, 181, 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Center(
                            child: Text(
                          dragNumbers.next.toString(),
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                        )),
                      ),
                    ),
                    DragWidget(dragNumbers),
                    DragTarget(
                      onLeave: (a) {
                        print(11);
                      },
                      builder:
                          (context, List<int> candidateData, rejectedData) {
                        if (keep != -1)
                          return Draggable(
                            data: keep,
                            onDragCompleted: () {
                              keep = -1;
                              setState(() {});
                            },
                            feedback: Material(
                              color: Color.fromRGBO(101, 213, 181, 0.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Center(
                                child: Container(
                                  height: 84,
                                  width: 84,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(101, 213, 181, 0.8),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Center(
                                      child: Text(
                                    keep.toString(),
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 42),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Center(
                                    child: Text(
                                  keep.toString(),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 42),
                                )),
                              ),
                            ),
                          );
                        else
                          return Container(
                            height: 84,
                            width: 84,
                            decoration: BoxDecoration(
                                color: candidateData.length > 0
                                    ? Color.fromRGBO(101, 213, 181, 0.8)
                                    : Colors.white38,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Center(
                                child: Text(
                              candidateData.length > 0
                                  ? candidateData[0].toString()
                                  : '',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 42),
                            )),
                          );
                      },
                      onWillAccept: (data) {
                        return keep == -1;
                      },
                      onAccept: (data) {
                        print(data);
                        keep = data;
                        startCalculation();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
