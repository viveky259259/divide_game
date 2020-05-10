import 'dart:math';

import 'package:doublegame/model/dragNumbers.dart';


class NumberDelegate {
  static DragNumbers generateRandomNumber(DragNumbers dragNumbers) {
    if (dragNumbers.currentNum == 0) {
      int currentValue = Random().nextInt(8) + 2;
      int next = Random().nextInt(8) + 2;
      int nextToNext = Random().nextInt(8) + 2;
      dragNumbers.currentNum = currentValue;
      dragNumbers.next = next;
      dragNumbers.nextToNext = nextToNext;
    } else {
      int newValue = Random().nextInt(8) + 2;
      dragNumbers.currentNum = dragNumbers.next;
      dragNumbers.next = dragNumbers.nextToNext;
      dragNumbers.nextToNext = newValue;
    }
  }
}
