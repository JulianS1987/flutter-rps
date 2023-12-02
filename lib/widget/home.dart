import 'package:flutter/material.dart';
import 'package:rock_paper_scissors/widget/play_screen.dart';

// Main window / start screen of the App
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rock Paper Scissors'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Game Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PlayScreen(numberOfRounds: 3)));
                    },
                    child: const Text('Best of 3'))),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  // maybe change the type of numberOfRounds to double, to use double.infinity
                                  const PlayScreen(numberOfRounds: 9999)));
                    },
                    child: const Text('Endless'))),
          ],
        ),
      ),
    );
  }
}
