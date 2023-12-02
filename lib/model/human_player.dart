import 'package:rock_paper_scissors/model/player.dart';

// class that represents a human player. It extends the Player class and sets
// isHuman to true.
class HumanPlayer extends Player {
  // call the super constructor and set isHuman to true
  HumanPlayer(String name) : super(name, isHuman: true);
}
