import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dividegame/interfaces/i_game_screen.dart';
import 'package:dividegame/model/dragNumbers.dart';
import 'package:dividegame/screens/game/GameScreeenController.dart';
import 'package:dividegame/screens/numberDelegate.dart';
import 'package:dividegame/screens/timerWidget.dart';
import 'package:flutter/material.dart';

import '../timerWidget.dart';
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

class UiKeyValue {
  Key uiKey;
  int value;

  UiKeyValue(
    this.value, {
    this.uiKey,
  });
}

class _GameScreenState extends State<GameScreen> with IGameScreen {
  bool isSuccessful = false;
  int keep = -1;
  int score = 0;
  DragNumbers dragNumbers;
  List<List<int>> datas;
  List<List<GlobalKey>> keys;
  bool restart;
  int currentScoreToOverride = 0;
  double eachGridSize;
  AssetsAudioPlayer assetsAudioPlayer;
  GameScreenController gameScreenController;
  ValueNotifier<int> level = ValueNotifier(0);

  void initState() {
    super.initState();
    gameScreenController = GameScreenController();
    assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    restart = false;
    datas = new List.generate(widget.x, (_) => new List(widget.y));
    keys = new List.generate(widget.x, (index) => new List(widget.y));
    dragNumbers = DragNumbers();
    NumberDelegate.generateRandomNumber(
        dragNumbers, NumberDelegate.getMaxNumConsideration(widget.x, widget.y));
    updateData();
  }

  void calculateEachGridSize(context) {
    eachGridSize =
        (MediaQuery.of(context).size.width - 32 - 48 - 8 * (widget.x - 1)) /
            widget.x;
    print(eachGridSize);
  }

  @override
  void updateData() {
    for (int i = 0; i < widget.x; i++) {
      for (int j = 0; j < widget.y; j++) {
        datas[i][j] = -1;
      }
    }

    score = 0;
    level.value = 0;
  }

  int calculateFibonacci(int num) {
    if (num == 0) return 0;
    return num + calculateFibonacci(num - 1);
  }

  @override
  void startCalculation() async {
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
    Pairs completePair;
    pairs.forEach((e) {
      print('${e.a} , ${e.b}');
      e.calculate();
      if (e.ans == null) return;
      if (e.ans == 1) {
        datas[e.i1][e.j1] = -1;
        datas[e.i2][e.j2] = -1;
        int score = e.a * e.b;
        this.score = this.score + (score > 0 ? score : score * -1);
        completePair = e;
      } else if (e.ans != -1) {
        if (e.ans < 0) {
          datas[e.i1][e.j1] = -1;
          datas[e.i2][e.j2] = e.ans * -1;
          recheck = true;
          int score = e.a * e.b;
          this.score = this.score + (score > 0 ? score : score * -1);
          completePair = e;
        } else if (e.ans > 0) {
          datas[e.i2][e.j2] = -1;
          datas[e.i1][e.j1] = e.ans;
          recheck = true;
          int score = e.a * e.b;
          this.score = this.score + (score > 0 ? score : score * -1);
          completePair = e;
        }
      }
    });
    setState(() {});
    if (completePair != null) {
      showBreakAnimation(keys[completePair.i1][completePair.j1].currentContext,
          completePair.ans);
      showBreakAnimation(keys[completePair.i2][completePair.j2].currentContext,
          completePair.ans);
      await Future.delayed(Duration(milliseconds: 375));

      startCalculation();
      return;
    }
    if (!recheck) {
      bool gameEnd = await checkIfGameEnds();
      if (!gameEnd) {
        gotoNextLevel();
      }
    }
  }

  Future<bool> checkIfGameEnds() async {
    bool gameEnds = true;
    for (int i = 0; i < widget.x; i++) {
      print(11);
      if (gameEnds)
        for (int k = 0; k < widget.y; k++) {
          print(12);
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
                content: Text(
                  '$score Scored',
                  style: TextStyle(color: Colors.black),
                ),
              ));
      setState(() {
        updateData();
        restart = false;
      });
    }
    return gameEnds;
  }

  @override
  void gotoNextLevel() {
    print('score: $score, override: $currentScoreToOverride');
    if (currentScoreToOverride == 0) calculateCurrentScoreToOverride();
    if (score > currentScoreToOverride) {
      currentScoreToOverride = 0;
      level.value++;
    }
  }

  @override
  void calculateCurrentScoreToOverride() {
    int fibNum = calculateFibonacci(level.value);
    currentScoreToOverride = fibNum * 123;
  }

  showBreakAnimation(BuildContext ctx, int ans) async {
    assetsAudioPlayer.open(Audio("asset/sounds/crash.mp3"));
    RenderBox renderBox = ctx.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    var center = Offset(
        offset.dx + size.width / 2 - 15, offset.dy + size.height / 2 - 15);
    Widget childToShow = Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            color: Color.fromRGBO(101, 213, 181, 0.8),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Center(
            child: Text(
          '${ans < 0 ? ans * -1 : ans}',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        )),
      ),
    );
    OverlayEntry topLeft = OverlayEntry(
        builder: (context) => Positioned(
              left: center.dx - size.width / 2 - 8,
              top: center.dy - size.height / 2 - 8 - 15,
              child: childToShow,
            ));
    OverlayEntry topCenter = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx,
            top: center.dy - size.height / 2 - 8 - 15,
            child: childToShow));
    OverlayEntry topRight = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx + size.width / 2 + 8,
            top: center.dy - size.height / 2 - 8 - 15,
            child: childToShow));
    OverlayEntry bottomLeft = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx - size.width / 2 - 8,
            top: center.dy + size.height / 2 + 15,
            child: childToShow));
    OverlayEntry bottomCenter = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx,
            top: center.dy + size.height / 2 + 15,
            child: childToShow));
    OverlayEntry bottomRight = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx + size.width / 2 + 8,
            top: center.dy + size.height / 2 + 15,
            child: childToShow));
    OverlayEntry centeright = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx + size.width / 2 + 8,
            top: center.dy,
            child: childToShow));
    OverlayEntry centerLeft = OverlayEntry(
        builder: (context) => Positioned(
            left: center.dx - size.width / 2 - 8,
            top: center.dy,
            child: childToShow));
    Overlay.of(context).insertAll([
      topRight,
      topLeft,
      topCenter,
      centeright,
      centerLeft,
      bottomRight,
      bottomLeft,
      bottomCenter
    ]);

    await Future.delayed(Duration(milliseconds: 375));
    topRight.remove();
    topLeft.remove();
    topCenter.remove();
    bottomRight.remove();
    bottomLeft.remove();
    bottomCenter.remove();
    centeright.remove();
    centerLeft.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (eachGridSize == null) calculateEachGridSize(context);
    print('hello');
    return Scaffold(
      key: gameScreenController.scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TimerWidget(restart, gameScreenController),
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
                const  SizedBox(
                  width: 16,
                ),
                Text(
                  '$score',
                  style: TextStyle(color: Colors.white70, fontSize: 32),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Level',
                        style: TextStyle(color: Colors.white70, fontSize: 24),
                      ),
                      const  SizedBox(
                        width: 12,
                      ),
                      ValueListenableBuilder(
                        valueListenable: level,
                        builder: (context, value, child) => Text(
                          '${value}',
                          style: TextStyle(color: Colors.white70, fontSize: 48),
                        ),
                      )
                    ],
                  ),
                ),
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
                const  SizedBox(
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
                    childrenDelegate: SliverChildBuilderDelegate((ctx, index) {
                      bool isAccepted = false;
                      int acceptedData;
                      int i = index ~/ widget.x;
                      int j = index % widget.y;
                      GlobalKey globalKey = GlobalKey();
                      keys[i][j] = globalKey;
                      return Builder(
                          builder: (ctx) => DragTarget(
                                key: globalKey,
                                onLeave: (a) {
                                  print(11);
                                },
                                builder: (context, List<int> candidateData,
                                    rejectedData) {
                                  if (datas[i][j] != -1)
                                    return Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                101, 213, 181, 0.8),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Center(
                                            child: Text(
                                          datas[i][j].toString(),
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 42),
                                        )),
                                      ),
                                    );
                                  else if (isAccepted)
                                    return Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                101, 213, 181, 0.8),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Center(
                                            child: Text(
                                          datas[i][j].toString(),
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 42),
                                        )),
                                      ),
                                    );
                                  else
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: candidateData.length > 0
                                              ? Color.fromRGBO(
                                                  101, 213, 181, 0.8)
                                              : Colors.white38,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Center(
                                          child: Text(
                                        candidateData.length > 0
                                            ? candidateData[0].toString()
                                            : '',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 42),
                                      )),
                                    );
                                },
                                onWillAccept: (data) {
                                  return datas[i][j] == -1;
                                },
                                onAccept: (data) async {
                                  assetsAudioPlayer
                                      .open(Audio("asset/sounds/click2.wav"));
                                  isAccepted = true;
                                  acceptedData = data;
                                  print(data);
                                  datas[i][j] = data;
                                  startCalculation();
                                },
                              ));
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
                    DragWidget(dragNumbers, widget.x, widget.y, datas),
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
