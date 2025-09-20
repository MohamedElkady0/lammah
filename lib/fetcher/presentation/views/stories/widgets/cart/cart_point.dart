// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class CartPoint extends StatelessWidget {
  const CartPoint({super.key});

  @override
  Widget build(BuildContext context) {
    String ds = 'خصم 53%EGP175,968.14';

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

// العدد و الخصم و الشحن مجانى ولا لأ و الارجاع و الباقات هل تريد عمل باقه
