import 'package:uuid/uuid.dart';

class PlayerId {
  final String _id;

  // generate a unique id for the player
  PlayerId() : _id = const Uuid().v8();

  String get id => _id;
}

// class that represents a player
abstract class Player {
  late final String _name;
  final bool _isHuman;
  int _winCounter = 0;
  final PlayerId _id = PlayerId();

  Player(this._name, {bool isHuman = false}) : _isHuman = isHuman;

  String get name => _name;
  bool get isHuman => _isHuman;
  int get winCounter => _winCounter;
  PlayerId get id => _id;

  void incrementWinCounter() {
    _winCounter++;
  }

  void resetWinCounter() {
    _winCounter = 0;
  }
}
