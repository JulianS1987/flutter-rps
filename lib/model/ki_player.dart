import 'dart:math';

import 'package:rock_paper_scissors/model/player.dart';
import 'package:rock_paper_scissors/types/enums.dart';

// class that represents a ki player. It extends the Player class and adds
// the choose method to return a random choice.
class KiPlayer extends Player {
  // call the super constructor and set isHuman to false
  KiPlayer(String name) : super(name, isHuman: false);

  Choice choose() {
    // get all possible choices from the Choice enum
    List<Choice> choices = Choice.values;
    // return a random choice
    return choices[Random().nextInt(choices.length)];
  }
}
