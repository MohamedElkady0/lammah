import 'package:flutter/material.dart';

class NoNoteYet extends StatefulWidget {
  const NoNoteYet({super.key});

  @override
  State<NoNoteYet> createState() => _NoNoteYetState();
}

class _NoNoteYetState extends State<NoNoteYet>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;
  late final Animation<double> fadeIn;

  @override
  void initState() {
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
    animation.forward();
    super.initState();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(opacity: fadeIn.value, child: child);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/productivity.png', height: 100),
            const SizedBox(height: 20),
            Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the + button to add a new note',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
