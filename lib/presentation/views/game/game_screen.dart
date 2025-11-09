import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameScreen extends StatelessWidget {
  final String gameId;
  const GameScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);

    return Scaffold(
      appBar: AppBar(title: const Text("Tic-Tac-Toe")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: gameRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> board = gameData['board'];
          final String currentPlayerUid = gameData['currentPlayerUid'];
          final String winner = gameData['winner'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                winner.isNotEmpty
                    ? (winner == "draw" ? "تعادل!" : "الفائز هو $winner")
                    : "دور اللاعب: $currentPlayerUid",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // السماح باللعب فقط إذا كان دورك والخانة فارغة واللعبة لم تنتهِ
                        if (currentPlayerUid == currentUserUid &&
                            board[index] == "" &&
                            winner.isEmpty) {
                          // تحديث اللوحة في Firestore
                          List<dynamic> newBoard = List.from(board);
                          newBoard[index] = "X"; // افترض أنك دائماً X

                          // تحديد اللاعب التالي
                          final otherPlayerUid = (gameData['players'] as List)
                              .firstWhere((uid) => uid != currentUserUid);

                          gameRef.update({
                            'board': newBoard,
                            'currentPlayerUid': otherPlayerUid,
                            // يمكنك هنا إضافة منطق للتحقق من الفوز
                          });
                        }
                      },
                      child: Card(
                        elevation: 4,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                            child: Text(
                              board[index],
                              key: ValueKey<String>(
                                board[index],
                              ), // مهم للـ AnimatedSwitcher
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: board[index] == 'X'
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
