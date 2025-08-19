import 'package:flutter/material.dart';

class CartPoint extends StatelessWidget {
  const CartPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown,
      width: MediaQuery.of(context).size.width * .1,
      height: MediaQuery.of(context).size.height * 0.1,
    );
  }
}
