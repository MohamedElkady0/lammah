import 'package:flutter/material.dart';

class CartPoint extends StatelessWidget {
  const CartPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.brown,
        width: MediaQuery.of(context).size.width * .4,
        height: MediaQuery.of(context).size.height * 0.3,
      ),
    );
  }
}
