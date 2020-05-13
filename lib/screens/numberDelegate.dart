import 'dart:math';

import 'package:dividegame/model/dragNumbers.dart';

class NumberDelegate {
  static DragNumbers generateRandomNumber(DragNumbers dragNumbers, int maxNum) {
    if (dragNumbers.currentNum == 0) {
      int currentValue = Random().nextInt(maxNum) + 3;
      int next = Random().nextInt(maxNum) + 3;
      int nextToNext = Random().nextInt(maxNum) + 3;
      dragNumbers.currentNum = currentValue;
      dragNumbers.next = next;
      dragNumbers.nextToNext = nextToNext;
    } else {
      int newValue = Random().nextInt(maxNum) + 3;
      dragNumbers.currentNum = dragNumbers.next;
      dragNumbers.next = dragNumbers.nextToNext;
      dragNumbers.nextToNext = newValue;
    }
  }

  static int getMaxNumConsideration(int x, int y) {
    return x * y + x + y;
  }
}
