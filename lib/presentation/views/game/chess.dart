// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_chess_board/flutter_chess_board.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Chess',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   final ChessBoardController controller = ChessBoardController();
//   bool isPlayerVsAI = false;

//   void _handlePlayerMove() {
//     // Check for game over after the player's move
//     if (_checkGameOver()) {
//       return; // If the game is over, don't proceed.
//     }

//     // If it's Player vs AI mode and it's black's turn, trigger AI move.
//     if (isPlayerVsAI && controller.game.turn == Color.BLACK) {
//       // Use a short delay to make the AI's move feel more natural
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _getAIMove();
//       });
//     }
//   }

//   // A simple AI that makes a random legal move
//   void _getAIMove() {
//     final List moves = controller.game.moves();
//     if (moves.isEmpty) {
//       return; // No legal moves available
//     }

//     final Random random = Random();
//     final Move randomMove = moves[random.nextInt(moves.length)];

//     controller.makeMove(from: randomMove.fromAlgebraic, to: randomMove.toAlgebraic);
//     setState(() {});

//     // Check for game over after the AI's move
//     _checkGameOver();
//   }

//   bool _checkGameOver() {
//     if (controller.isCheckMate()) {
//       _showGameOverDialog('Checkmate!');
//       return true;
//     } else if (controller.isDraw()) {
//       _showGameOverDialog('Draw!');
//       return true;
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chess Game'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: ChessBoard(
//                 controller: controller,
//                 boardColor: BoardColor.green,
//                 boardOrientation: PlayerColor.white,
//                 onMove: _handlePlayerMove,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               alignment: WrapAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isPlayerVsAI = true;
//                       controller.resetBoard();
//                     });
//                   },
//                   child: const Text('Player vs AI'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isPlayerVsAI = false;
//                       controller.resetBoard();
//                     });
//                   },
//                   child: const Text('Player vs Player'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     controller.resetBoard();
//                     setState(() {});
//                   },
//                   child: const Text('Reset Game'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showGameOverDialog(String title) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: const Text('The game is over. Would you like to play again?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Play Again'),
//               onPressed: () {
//                 controller.resetBoard();
//                 Navigator.of(context).pop();
//                 setState(() {});
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
