import 'package:flutter/material.dart';

class CategoryButtonsShop extends StatelessWidget {
  const CategoryButtonsShop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(50),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary.withAlpha(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Image.asset('assets/images/money-bag.png', width: 35),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset('assets/images/money.png', width: 35),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset('assets/images/price-tag.png', width: 35),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset('assets/images/store.png', width: 35),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
