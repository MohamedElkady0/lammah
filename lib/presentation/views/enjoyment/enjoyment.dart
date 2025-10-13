import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/enjoyment/widget/drawer_enjoy.dart';

class Enjoyment extends StatelessWidget {
  const Enjoyment({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    print("News page build: Using key ${scaffoldKey.hashCode}");
    return Scaffold(
      drawer: DrawerEnjoy(),
      appBar: AppBar(
        title: Text('News'),
        // leading: IconButton(
        //   icon: Icon(Icons.menu),
        //   onPressed: () {
        //     Scaffold.of(context).openDrawer();
        //   },
        // ),
      ),
      key: scaffoldKey,

      backgroundColor: Theme.of(context).colorScheme.primary,

      body: SafeArea(
        child: Center(
          child: Text(
            'Enjoyment',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
