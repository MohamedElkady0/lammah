import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/game/game_screen.dart';

class GameLobbyScreen extends StatefulWidget {
  final String chatRoomId;
  final String currentUserUid;
  final String otherUserUid;

  const GameLobbyScreen({
    super.key,
    required this.chatRoomId,
    required this.currentUserUid,
    required this.otherUserUid,
  });

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  late DocumentReference lobbyRef;

  @override
  void initState() {
    super.initState();
    lobbyRef = FirebaseFirestore.instance
        .collection('gameLobbies')
        .doc(widget.chatRoomId);

    // إنشاء أو تحديث مستند اللوبي عند الدخول
    lobbyRef.set({
      'status': 'browsing',
      'proposedGameId': '',
      'proposerUid': '',
      'players': {
        widget.currentUserUid: 'browsing',
        widget.otherUserUid: 'browsing',
      },
      'activeGameSessionId': '',
    }, SetOptions(merge: true));
  }

  // وظيفة لاقتراح لعبة
  void _proposeGame(String gameId) {
    lobbyRef.update({
      'status': 'proposed',
      'proposedGameId': gameId,
      'proposerUid': widget.currentUserUid,
      'players.${widget.currentUserUid}': 'proposed',
    });
  }

  // وظيفة للموافقة على اللعبة المقترحة
  void _agreeToGame(String gameId, String proposerUid) async {
    var nav = Navigator.of(context);
    // 1. إنشاء جلسة لعبة جديدة
    final gameSession = await FirebaseFirestore.instance
        .collection('games')
        .add({
          'players': [widget.currentUserUid, widget.otherUserUid],
          'board': List.generate(9, (_) => ""), // لوحة فارغة (خاص بلعبة XO)
          'currentPlayerUid': proposerUid, // المقترح يبدأ
          'winner': "",
          'status': "playing",
        });

    // 2. تحديث اللوبي وتأكيد الموافقة
    lobbyRef.update({
      'status': 'playing',
      'players.${widget.currentUserUid}': 'agreed',
      'activeGameSessionId': gameSession.id,
    });

    // 3. الانتقال إلى شاشة اللعبة
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(gameId: gameSession.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("بيت الألعاب")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: lobbyRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final lobbyData = snapshot.data!.data() as Map<String, dynamic>;
          final status = lobbyData['status'] ?? 'browsing';
          final proposedGameId = lobbyData['proposedGameId'] ?? '';
          final proposerUid = lobbyData['proposerUid'] ?? '';

          return GridView(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            children: [
              _buildGameCard(
                gameName: "Tic-Tac-Toe",
                gameId: "tic_tac_toe",
                lobbyStatus: status,
                proposedGameId: proposedGameId,
                proposerUid: proposerUid,
              ),
              _buildGameCard(
                gameName: "شطرنج",
                gameId: "chess",
                lobbyStatus: status,
                proposedGameId: proposedGameId,
                proposerUid: proposerUid,
              ),
              // ... أضف ألعاباً أخرى هنا
            ],
          );
        },
      ),
    );
  }

  // هذه الويدجت هي الأهم، فهي تعرض الحالة الصحيحة لكل لعبة
  Widget _buildGameCard({
    required String gameName,
    required String gameId,
    required String lobbyStatus,
    required String proposedGameId,
    required String proposerUid,
  }) {
    bool isProposedByMe =
        (proposerUid == widget.currentUserUid && proposedGameId == gameId);
    bool isProposedByOther =
        (proposerUid == widget.otherUserUid && proposedGameId == gameId);
    // bool isSelectable = (lobbyStatus == 'browsing');

    // تحديد محتوى البطاقة بناءً على الحالة
    Widget cardContent;
    Color cardColor = Colors.white;
    VoidCallback? onTapAction = () => _proposeGame(gameId);

    if (isProposedByMe) {
      cardContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("في انتظار موافقة صديقك..."),
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
        ],
      );
      cardColor = Colors.orange.shade100;
      onTapAction = null; // لا تفعل شيئاً عند الضغط
    } else if (isProposedByOther) {
      cardContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("صديقك اختار هذه اللعبة!"),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _agreeToGame(gameId, proposerUid),
            child: const Text("وافق والعب"),
          ),
        ],
      );
      cardColor = Colors.green.shade100;
      onTapAction = () => _agreeToGame(gameId, proposerUid);
    } else {
      // الحالة العادية أو لعبة أخرى غير مقترحة
      cardContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.games, size: 40),
          const SizedBox(height: 8),
          Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
      // إذا كانت هناك لعبة مقترحة، يتم تعطيل البطاقات الأخرى
      if (lobbyStatus == 'proposed') {
        cardColor = Colors.grey.shade300;
        onTapAction = null;
      }
    }

    return InkWell(
      onTap: onTapAction,
      child: Card(
        color: cardColor,
        elevation: 4,
        child: Padding(padding: const EdgeInsets.all(8.0), child: cardContent),
      ),
    );
  }
}
