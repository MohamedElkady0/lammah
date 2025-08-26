import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/presentation/views/news/view/add_news.dart';

class AppBarNews extends StatelessWidget {
  const AppBarNews({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          const Text('Lammah'),
          const SizedBox(width: 10),
          Image.asset(AuthString.logo, width: 50),
        ],
      ),
      centerTitle: true,
      actions: [
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => AddNews()));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/add-button.png', width: 45),
          ),
        ),
      ],
      leading: Container(),
    );
  }
}
