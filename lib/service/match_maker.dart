import 'package:rock_paper_scissors/model/player.dart';
import 'package:rock_paper_scissors/types/enums.dart';

// class definiton for single round
class Round {
  List<PlayerId> winner = [];
  List<PlayerId> loser = [];
  List<PlayerId> draw = [];
  Map<PlayerId, Choice> choices = {};
}

class MatchMaker {
  // list of players, will be filled with initialPlayers constructor parameter
  final List<Player> _players = [];

  // maximum number of rounds, will be set with constructor parameter
  final double _maxRounds;

  // list of rounds
  final List<Round> _rounds = [];

  // will be initialized in constructor
  // _currentPlayer is the player that has to make a choice, will be set to first player in _players
  // when _players the game starts and cyled through _players when _currentRound is complete
  late Player _currentPlayer;
  // _currentRound is the current round, will be set to a new round when game starts or _currentRound is complete
  late Round _currentRound;
  // required number of wins to win the game, will be calculated in the constructor
  late double _requiredWins;

  // pubblic getter
  int get playerCount => _players.length;
  List<Player> get players => _players;

  // Callback functions that has to be subscribed when constructor is called
  // Callback fuction to notify parent widget that current player has changed
  final Function(Player) onCurrentPlayerChanged;
  // Callback function to notify parent widget that round has changed
  final Function(int) onRoundChanged;

  // Callback functions that can be subscribed after initialization
  // Callback fuction to notify parent widget that game is finished
  Function(bool)? onGameIsActiveChanged;
  // Callback fuction to notify parent widget that winner text has changed
  Function(String?)? onGameOutcomeTextChanged;

  // constructor
  MatchMaker(
    List<Player> initialPlayers,
    this._maxRounds, {
    required this.onCurrentPlayerChanged,
    required this.onRoundChanged,
  }) {
    // add all players from initialPlayers to _players
    _players.addAll(initialPlayers);
    // set _currentPlayer to first player in _players when _players is not empty
    if (_players.isNotEmpty) {
      _currentPlayer = _players.first;
      // notify parent widget that current player has changed
      onCurrentPlayerChanged(_currentPlayer);
    }
    // calculate required wins to win the game
    // if _maxRounds is infinity, set _requiredWins to infinity
    // else set _requiredWins to (_maxRounds ~/ 2) + 1
    _requiredWins =
        _maxRounds != double.infinity ? (_maxRounds ~/ 2) + 1 : double.infinity;
    // start first round
    _startNewRound();
  }

  // set choice of _currentPlayer, if _currentRound is complete, update gameOutcomeText and increment win counter of winner
  // if game is not over, start new round and set _currentPlayer to next player in _players
  // if game is over, notify parent widget that game is finished and update gameOutcomeText with overall winner
  void setCurrentPlayerAction(Choice choice) {
    // set choice of _currentPlayer in _currentRound
    _currentRound.choices[_currentPlayer.id] = choice;
    // check if _currentRound is complete
    if (_isRoundComplete()) {
      PlayerId? winnerId = _determineWinner(_currentRound);
      // if winner is not null, increment win counter of winner and start new round if played rounds are less than _maxRounds
      if (winnerId != null) {
        // increment win counter of winner
        // every player in _players has a unique id, so we can use the id of the winner to find the corresponding player in _players
        _players
            .firstWhere((player) => player.id == winnerId)
            .incrementWinCounter();
        // check if a player is a early winner who reached the required number of wins to win the game
        if (_players.any((player) => player.winCounter == _requiredWins)) {
          // if a player is a early winner, finish the game
          _finishGame();
        } else if (_rounds.length < _maxRounds) {
          // if played rounds are less than _maxRounds, start new round and set _currentPlayer to next player in _players

          // build game outcome string and notify parent widget
          _buildRoundOutcomeStringAndNotifyParent(
              players, _currentRound.choices, winnerId);
          // start new round
          _startNewRound();
          // set _currentPlayer to next player in _players
          _nextPlayer();
        } else {
          // if played rounds are equal to _maxRounds, finish the game
          _finishGame();
        }
      } else {
        // if winner is null (draw), reset round (restart current round) and set _currentPlayer to next player in _players
        // reset game outcome text
        _notifyGameOutcomeTextChanged('Draw!');
        _resetRound();
        _nextPlayer();
      }
    } else {
      // if _currentRound is not complete, set _currentPlayer to next player in _players
      _nextPlayer();
    }
  }

  // reset game and notify parent widget
  void resetGame() {
    // reset _rounds
    _rounds.clear();
    // reset win counter of all players in _players
    for (Player player in _players) {
      player.resetWinCounter();
    }
    // notify parent widget that game is active again
    onGameIsActiveChanged!(true);
    // reset game outcome text
    _notifyGameOutcomeTextChanged(null);
    // start new first round
    _startNewRound();
    // set _currentPlayer to next (first) player in _players
    _nextPlayer();
  }

  // finish the game
  void _finishGame() {
    // build game outcome string and notify parent widget
    _buildGameOutcomeStringAndNotifyParent(players);
    // notify parent widget that game is finished
    onGameIsActiveChanged!(false);
  }

  // start new round and notify parent widget that round has changed
  void _startNewRound() {
    // create new round
    final newRound = Round();
    // set _currentRound to new round
    _currentRound = newRound;
    // add new round to _rounds
    _rounds.add(newRound);
    // notify parent widget that round has changed
    onRoundChanged(_rounds.length);
  }

  // reset round on draw and notify parent widget that round has changed
  void _resetRound() {
    // remove current round from _rounds
    _rounds.removeLast();
    // restart round
    _startNewRound();
  }

  // set _currentPlayer to next player in _players and notify parent widget that current player has changed
  void _nextPlayer() {
    // get index of _currentPlayer in _players
    int currentIndex = _players.indexOf(_currentPlayer);
    // calculate next index by incrementing currentIndex by 1, if currentIndex is last index in _players
    int nextIndex = (currentIndex + 1) % _players.length;
    // set _currentPlayer to player at nextIndex in _players
    _currentPlayer = _players[nextIndex];
    // notify parent widget that current player has changed
    onCurrentPlayerChanged(_currentPlayer);
  }

  // check if _currentRound is complete
  bool _isRoundComplete() {
    // return true if number of choices in _currentRound is equal to number of players in _players (all players had made a choice)
    return _currentRound.choices.length == _players.length;
  }

  // determine winner of _currentRound and return player id of winner or null if there is no winner.
  // the idea is to determine all unique choices and then check if there is a choice that wins against every other choice.
  // the funtion first checks if all choices are equal, to terminate early if that is the case.
  // Otherwise:
  // if there is a choice that wins against every other choice, determine players that picked that choice.
  // if there are multiple players that picked that choice, the game is draw.
  // if there is only one player that picked that choice, that player is the winner.
  // if there is no choice that wins against every other choice, the game is draw too.
  PlayerId? _determineWinner(Round round) {
    // get list of all choices in _currentRound
    List<Choice> choices = round.choices.values.toList();

    // get list of all player ids in _currentRound
    List<PlayerId> playerIds = round.choices.keys.toList();

    // determine if all choices are equal
    bool allEqual = choices.every((choice) => choice == choices.first);

    // if all choices are equal, add all player ids to draw list in _currentRound
    if (allEqual) {
      // add all player ids to draw list in _currentRound
      round.draw.addAll(playerIds);
      return null;
    } else {
      // get unique choices in _currentRound
      Set<Choice> uniqueChoices = choices.toSet();

      // create map to store which choices wins against which other choices
      Map<Choice, Set<Choice>> winsAgainstOthers =
          _createChoiceWinsAgainstOthersMap(uniqueChoices);

      // determine if there is a choice that wins against all other choices
      Choice? winnerChoice =
          _evaluateWinnerChoice(winsAgainstOthers, uniqueChoices);

      // if there is a choice that wins against every other choice, determine players that picked that choice and return player id of winner. Else return null
      return _evaluatePlayerWithWinnerChoice(winnerChoice, round, playerIds);
    }
  }

  // returns a map that stores which choices wins against which other choices
  Map<Choice, Set<Choice>> _createChoiceWinsAgainstOthersMap(
      Set<Choice> uniqueChoices) {
    Map<Choice, Set<Choice>> winsAgainstOthers = {
      for (Choice choice in uniqueChoices) choice: <Choice>{}
    };

    // choice beats other choices definition
    const winsAgainst = {
      Choice.rock: [Choice.scissors],
      Choice.scissors: [Choice.paper],
      Choice.paper: [Choice.rock],
    };

    // check which choices wins against which other choices
    for (Choice choice in uniqueChoices) {
      for (Choice opponent in uniqueChoices) {
        if (choice != opponent) {
          // check if choice wins against opponent
          if (winsAgainst[choice]!.contains(opponent)) {
            winsAgainstOthers[choice]!.add(opponent);
          }
        }
      }
    }
    return winsAgainstOthers;
  }

  // if there is a choice that wins against every other choice, return that choice. Else return null
  Choice? _evaluateWinnerChoice(
      Map<Choice, Set<Choice>> winsAgainstOthers, Set<Choice> uniqueChoices) {
    Choice? winnerChoice;
    // iterate over winsAgainstOthers map
    for (var entry in winsAgainstOthers.entries) {
      // if length of value list is equal to length of uniqueChoices list minus 1, there is a choice that wins against all other choices
      if (entry.value.length == uniqueChoices.length - 1) {
        winnerChoice = entry.key;
        break;
      }
    }
    return winnerChoice;
  }

  // if there is a choice that wins against every other choice and only one player picked that choice, return player id of winner. Else return null
  PlayerId? _evaluatePlayerWithWinnerChoice(
      Choice? winnerChoice, Round round, List<PlayerId> playerIds) {
    if (winnerChoice != null) {
      // determine winners of _currentRound
      List<PlayerId> winners = _findWinners([winnerChoice], round.choices);
      // determine losers of _currentRound
      List<PlayerId> losers = _findLosers(winners, round.choices);
      // add losers to loser list in _currentRound
      round.loser.addAll(losers);
      // if there is only one winner, add winner to winner list in _currentRound and return player id of winner
      if (winners.length == 1) {
        PlayerId winner = winners.first;
        round.winner.add(winner);
        return winner;
      } else {
        // if there are multiple winners (multiple players with winner choice), add winners to draw list in _currentRound and return null
        round.draw.add(winners.first);
        return null;
      }
    } else {
      // if there is no choice that wins against every other choice, game is draw. Add all player ids to draw list in _currentRound and return null
      round.draw.addAll(playerIds);
      return null;
    }
  }

  // determine winners of _currentRound
  List<PlayerId> _findWinners(
      List<Choice> winningChoices, Map<PlayerId, Choice> choices) {
    List<PlayerId> winners = [];
    // iterate over choices map
    for (var entry in choices.entries) {
      // if winningChoices contains choice of entry, add player id of entry to winners list
      if (winningChoices.contains(entry.value)) {
        winners.add(entry.key);
      }
    }
    return winners;
  }

  // determine losers of _currentRound (all players that are not winners)
  List<PlayerId> _findLosers(
      List<PlayerId> winnerIds, Map<PlayerId, Choice> choices) {
    List<PlayerId> losers = [];
    // iterate over choices map
    for (var entry in choices.entries) {
      // if winnerIds does not contain player id of entry, add player id of entry to losers list
      if (!winnerIds.contains(entry.key)) {
        losers.add(entry.key);
      }
    }
    return losers;
  }

  void _buildGameOutcomeStringAndNotifyParent(List<Player> players) {
    // get player with highest win counter
    Player winner =
        players.reduce((a, b) => a.winCounter > b.winCounter ? a : b);
    // build game outcome string in the following format: 'winnerName wins the game!'
    String gameOutcomeText = '${winner.name} wins the game!';
    // notify parent widget that game outcome text has changed
    _notifyGameOutcomeTextChanged(gameOutcomeText);
  }

  // build round outcome string
  void _buildRoundOutcomeStringAndNotifyParent(
      List<Player> players, Map<PlayerId, Choice> choices, PlayerId winner) {
    // get winner name
    String winnerName =
        players.firstWhere((player) => player.id == winner).name;
    // get winner choice
    Choice winnerChoice = choices[winner]!;
    // get loser ids
    List<PlayerId> loserIds = choices.keys.where((id) => id != winner).toList();
    // get loser names and choices as Map
    Map<String, Choice> loserNamesChoiceMap =
        _createLoserNameChoiceMap(loserIds, players, choices);
    // build game outcome string in the following format:
    // '{winnerName} beats {loserName1} ({loser1Choice}), {loserName2} ({loser2Choice}), ... with {winnerChoice}'
    String gameOutcomeText = '$winnerName beats ';
    // iterate over loserNamesChoiceMap
    for (var entry in loserNamesChoiceMap.entries) {
      // add loser name and choice to game outcome string
      gameOutcomeText +=
          '${entry.key} (${entry.value.toString().split('.').last}), ';
    }
    // add winner choice to game outcome string
    gameOutcomeText += 'with ${winnerChoice.toString().split('.').last}';
    // notify parent widget that game outcome text has changed
    _notifyGameOutcomeTextChanged(gameOutcomeText);
  }

  // create map of loser names and choices
  Map<String, Choice> _createLoserNameChoiceMap(List<PlayerId> loserIds,
      List<Player> players, Map<PlayerId, Choice> choices) {
    // create map to store loser names and choices
    Map<String, Choice> loserNamesAndChoices = {};
    // iterate over loser ids and add loser name and choice to loserNamesAndChoices map
    for (PlayerId id in loserIds) {
      String name = players.firstWhere((player) => player.id == id).name;
      Choice choice = choices[id]!;
      loserNamesAndChoices[name] = choice;
    }
    return loserNamesAndChoices;
  }

  // function to notify parent about the gameOutcomeText Text changed
  void _notifyGameOutcomeTextChanged(String? gameOutcomeText) {
    // notify parent
    onGameOutcomeTextChanged!(gameOutcomeText);
  }
}
