import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/stories/views/new_shop.dart';
import 'package:lammah/presentation/views/stories/widgets/drawer_shop.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.primary,
        drawer: DrawerShop(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewShop()),
                );
              },
              child: Image.asset('assets/images/save-money.png', width: 35),
            ),
          ],
          title: Image.asset('assets/images/shopping.png', width: 50),
          centerTitle: true,
        ),
      ),
    );
  }
}
