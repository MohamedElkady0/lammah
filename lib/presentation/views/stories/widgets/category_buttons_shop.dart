import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CategoryButtonsShop extends StatelessWidget {
  const CategoryButtonsShop({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return Container(
      padding: EdgeInsets.all(width * 0.02),
      margin: EdgeInsets.symmetric(horizontal: width * 0.01, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Image.asset(
              'assets/images/money-bag.png',
              width: width * 0.06,
            ),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset('assets/images/money.png', width: width * 0.06),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset(
              'assets/images/price-tag.png',
              width: width * 0.06,
            ),
            onTap: () {},
          ),
          InkWell(
            child: Image.asset('assets/images/store.png', width: width * 0.06),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
