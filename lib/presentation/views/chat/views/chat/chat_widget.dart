import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.message});
  final Map<String, dynamic> message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: InkWell(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('are you sure ?'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('yes')),
                  TextButton(onPressed: () {}, child: const Text('no')),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  message['message'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(DateFormat.jm().format(message['date'].toDate())),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatWidgetForFried extends StatelessWidget {
  const ChatWidgetForFried({super.key, required this.message});
  final Map<String, dynamic> message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('are you sure ?'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('yes')),
                  TextButton(onPressed: () {}, child: const Text('no')),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  message['message'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(DateFormat.jm().format(message['date'].toDate())),
            ],
          ),
        ),
      ),
    );
  }
}
