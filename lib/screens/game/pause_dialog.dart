import 'package:flutter/material.dart';

class PauseDialog extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldStateKey;

  PauseDialog(this.scaffoldStateKey);

  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 24,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Center(
                        child: Text(
                  'Paused',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ))),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.grey,
                          style: BorderStyle.solid,
                          width: 3)),
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              padding: EdgeInsets.all(8),
              onPressed: () {
                scaffoldStateKey.currentState.showSnackBar(SnackBar(
                  content: Text('Coming soo'),
                ));
              },
              color: Color(0xff4B87B9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Leader Board',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Icon(
                    Icons.poll,
                    size: 40,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              padding: EdgeInsets.all(8),
              onPressed: () {
                scaffoldStateKey.currentState.showSnackBar(SnackBar(
                  content: Text('Coming soo'),
                ));
              },
              color: Colors.pink.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Home',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Icon(
                    Icons.home,
                    size: 40,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              padding: EdgeInsets.all(8),
              color: Colors.green.shade700,
              onPressed: () {
                scaffoldStateKey.currentState.showSnackBar(SnackBar(
                  content: Text('Coming soo'),
                ));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Restart',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Icon(
                    Icons.restore,
                    size: 40,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
