import 'package:flutter/material.dart';
import 'package:lammah/fetcher/data/const/list_shop.dart';

class DrawerShop extends StatelessWidget {
  const DrawerShop({super.key});

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
                  image: AssetImage('assets/images/online-shopping.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.black12,
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.person_2_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.card_giftcard,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              title: Text(
                'Points & Rewards',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            ExpansionTile(
              iconColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(
                'Category',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              leading: Icon(
                Icons.category,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              children: [
                for (var i = 0; i < ListShop.category.length; i++)
                  ListTile(
                    onTap: () {},
                    leading: Icon(
                      ListShop.iconShop[i],
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    title: Text(
                      ListShop.category[i],
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
