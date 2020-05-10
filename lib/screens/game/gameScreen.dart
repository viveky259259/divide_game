import 'package:flutter/material.dart';

import 'drag_widget.dart';

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

  int currentValue = 10;
  List<List<int>> matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ];
  List<List<int>> datas;

  void initState() {
    super.initState();
    datas = new List.generate(widget.x, (_) => new List(widget.y));
    updateData();
  }

  void updateData() {
    for (int i = 0; i < widget.x; i++) {
      for (int j = 0; j < widget.y; j++) {
        datas[i][j] = -1;
      }
    }
    print(datas);
  }

  void startCalculation() {
    //check horizontal
    List<Pairs> pairs = List();
    for (int i = 0; i < widget.x; i++) {
      for (int k = 0; k < widget.y - 1; k++) {
        int a = datas[i][k];
        int b = datas[i][k + 1];
        Pairs first;
        if (a * b > 0 && (a!=-1 && b!=-1)) first = Pairs(a, b, i, k, i, k+1);

        if (first != null) pairs.add(first);
      }
//      int a = datas[i][0];
//      int b = datas[i][1];
//      int c = datas[i][2];
//
//      Pairs first, second;
//      if (a * b > 0) first = Pairs(a, b, i, 0, i, 1);
//      if (b * c > 0) second = Pairs(b, c, i, 1, i, 2);
//      if (first != null) pairs.add(first);
//      if (second != null) pairs.add(second);
    }
    pairs.forEach((e) {
      print('${e.a} , ${e.b}');
      e.calculate();
      if (e.ans == null) return;
      if (e.ans == 1) {
        datas[e.i1][e.j1] = -1;
        datas[e.i2][e.j2] = -1;
      } else if (e.ans != -1) {
        if (e.ans < 0) {
          datas[e.i1][e.j1] = -1;
          datas[e.i2][e.j2] = e.ans * -1;
        } else if (e.ans > 0) {
          datas[e.i2][e.j2] = -1;
          datas[e.i1][e.j1] = e.ans;
        }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
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
                  '1046',
                  style: TextStyle(color: Colors.white70, fontSize: 32),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    updateData();
                    setState(() {});
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
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 4)),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.pause,
                    size: 32,
                    color: Colors.white70,
                  ),
                )
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
                                  color:  candidateData.length > 0 ? Color.fromRGBO(101, 213, 181, 0.8):Colors.white38,
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
                        onWillAccept: (data){
                          return  datas[i][j] == -1;
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
                          '15',
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
                          '18',
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                        )),
                      ),
                    ),
                    DragWidget(),
                    Center(
                      child: Container(
                        height: 102,
                        width: 102,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(101, 213, 181, 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Center(
                            child: Text(
                          '15',
                          style: TextStyle(color: Colors.white70, fontSize: 64),
                        )),
                      ),
                    ),
                    Draggable(
                      data: 'Flutter',
                      child: FlutterLogo(
                        size: 100.0,
                      ),
                      feedback: FlutterLogo(
                        size: 100.0,
                      ),
                      childWhenDragging: Container(),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: DragTarget(
                      builder:
                          (context, List<int> candidateData, rejectedData) {
                        return Center(
                          child: isSuccessful
                              ? Padding(
                                  padding: EdgeInsets.only(top: 100.0),
                                  child: Container(
                                    color: Colors.yellow,
                                    height: 200.0,
                                    width: 200.0,
                                    child: FlutterLogo(
                                      size: 100.0,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 200.0,
                                  width: 200.0,
                                  color: Colors.yellow,
                                ),
                        );
                      },
                      onWillAccept: (data) {
                        return true;
                      },
                      onAccept: (data) {
                        setState(() {
                          isSuccessful = true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: DragTarget(
                      onLeave: (a) {
                        print(11);
                      },
                      builder:
                          (context, List<int> candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                              color:
                                  isSuccessful ? Colors.white : Colors.white38,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        );
                      },
                      onWillAccept: (data) {
                        return true;
                      },
                      onAccept: (data) {
                        setState(() {
                          isSuccessful = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 32,
                  ),
                  Expanded(
                    child: DragTarget(
                      onLeave: (a) {
                        print(11);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        );
                      },
                      onWillAccept: (data) {
                        return true;
                      },
                      onAccept: (data) {
                        print(data);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
