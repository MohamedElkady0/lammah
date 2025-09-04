import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/presentation/views/stories/views/new_shop.dart';

class AppBarShop extends StatelessWidget {
  const AppBarShop({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const NewShop()));
          },
          child: Stack(
            children: [
              Image.asset('assets/images/save-money.png', width: 35),
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset('assets/images/diamond.png', width: 13),
              ),
            ],
          ),
        ),
      ],
      title: Image.asset(AuthString.logo, width: 50),
      centerTitle: true,
    );
  }

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
