import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/fetcher/data/const/list_shop.dart';

class DrawerMain extends StatelessWidget {
  const DrawerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,

      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/money.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      FontAwesomeIcons.store,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Shopping Now',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                        fontFamily: GoogleFonts.lobster().fontFamily,

                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < ListShop.category.length; i++)
              ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                title: Text(
                  ListShop.category[i],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
