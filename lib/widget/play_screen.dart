import 'package:flutter/material.dart';
import 'package:rock_paper_scissors/model/human_player.dart';
import 'package:rock_paper_scissors/model/ki_player.dart';
import 'package:rock_paper_scissors/model/player.dart';
import 'package:rock_paper_scissors/service/match_maker.dart';
import 'package:rock_paper_scissors/types/enums.dart';

// PlayScreen is the screen where the game is played. It displays the current
// round, the current player, the scoreboard and the buttons to choose.
class PlayScreen extends StatefulWidget {
  final int numberOfRounds;

  const PlayScreen({Key? key, required this.numberOfRounds}) : super(key: key);

  // create state for PlayScreen
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  // matchMaker is the core of the game. It handles the game logic and
  // communicates with the UI via callbacks. Will be initialized in initState.
  late MatchMaker _matchMaker;
  // currentRound is used to display the current round in the UI. Will be updated
  // by the matchMaker.
  int _currentRoundNumber = 1;
  // gameIsActive is used to display the current game state in the UI. Will be
  // updated by the matchMaker.
  bool _gameIsActive = true;
  // currentPlayer is used to display the current player in the UI. Will be
  // updated by the matchMaker.
  Player? _currentPlayer;
  // winnerText is used to display the winner of the game in the UI. Will be
  // updated by the matchMaker.
  String? _gameOutcomeText;

  @override
  void initState() {
    super.initState();
    // Initialize the matchMaker with two players, one human and one ki player.
    _matchMaker = MatchMaker([
      HumanPlayer('Human'),
      KiPlayer('Bot'),
    ], widget.numberOfRounds,
        onCurrentPlayerChanged: _updateCurrentPlayer,
        onRoundChanged: _updateCurrentRoundNumber);

    // handle the gameIsActive state change and update local var.
    _matchMaker.onGameIsActiveChanged = (isActive) {
      setState(() {
        _gameIsActive = isActive;
      });
    };

    // handle the winnerText state change and update local var to display the outcome of the the last round or to display
    // the winner if game is over.
    _matchMaker.onGameOutcomeTextChanged = (String? text) {
      setState(() {
        _gameOutcomeText = text;
      });
    };
  }

  // Method to update the current round number in the UI.
  void _updateCurrentRoundNumber(int round) {
    setState(() {
      _currentRoundNumber = round;
    });
  }

  // Method to update the current player in the UI and if the current player is a
  // ki player, let it choose.
  void _updateCurrentPlayer(Player player) {
    setState(() {
      // Update the current player.
      _currentPlayer = player;
      // If the current player is a ki player, let it choose.
      if (_currentPlayer is KiPlayer) {
        _matchMaker
            .setCurrentPlayerAction((_currentPlayer as KiPlayer).choose());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display the current round in the app bar.
        title: Text('Round $_currentRoundNumber'),
      ),
      body: Column(
        children: <Widget>[
          // Scoreboard
          Flexible(
            child: ListView.builder(
              itemCount: _matchMaker.playerCount,
              itemBuilder: (context, index) {
                List<Player> players = _matchMaker.players;
                return ListTile(
                  title: Text(players[index].name),
                  subtitle: Text('Score: ${players[index].winCounter}'),
                );
              },
            ),
          ),
          if (_gameOutcomeText != null)
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text('$_gameOutcomeText')),
          // Display the current player if it is not null and the game is active.
          if (_currentPlayer != null && _gameIsActive)
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text('${_currentPlayer!.name}`s turn')),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // if gameIsActive, display the buttons for the player to choose
          children: _gameIsActive
              ? <Widget>[
                  // maybe refactor to for-loop over Choice.values and create a
                  // dedicated ChoiceButton widget
                  OutlinedButton(
                    onPressed: () {
                      _matchMaker.setCurrentPlayerAction(Choice.rock);
                    },
                    child: const Text('Rock'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _matchMaker.setCurrentPlayerAction(Choice.paper);
                    },
                    child: const Text('Paper'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _matchMaker.setCurrentPlayerAction(Choice.scissors);
                    },
                    child: const Text('Scissors'),
                  )
                ]
              :
              // if game is not active (finished), display a button to restart the game
              <Widget>[
                  OutlinedButton(
                      onPressed: () {
                        _matchMaker.resetGame();
                      },
                      child: const Text('Restart'))
                ],
        ),
      ),
    );
  }
}
