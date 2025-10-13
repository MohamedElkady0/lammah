import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.currentIndex, this.onTabChange});
  final int currentIndex;
  final void Function(int)? onTabChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Theme.of(context).colorScheme.onPrimary,
            hoverColor: Theme.of(context).colorScheme.tertiary,
            haptic: true,
            tabBorderRadius: 15,
            tabActiveBorder: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1,
            ),
            tabBorder: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              width: 1,
            ),
            tabShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                blurRadius: 8,
              ),
            ],
            curve: Curves.easeOutExpo,

            gap: 8,
            color: Theme.of(context).colorScheme.onPrimary,
            activeColor: Theme.of(context).colorScheme.primary,

            tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 100),

            tabs: [
              GButton(
                iconSize: 16,
                icon: FontAwesomeIcons.house,
                text: '',
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
              GButton(
                iconSize: 16,
                icon: FontAwesomeIcons.store,
                text: '',
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
              GButton(
                iconSize: 16,
                icon: FontAwesomeIcons.newspaper,
                text: '',
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),

              GButton(
                iconSize: 16,
                icon: FontAwesomeIcons.film,
                text: '',
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
              GButton(
                iconSize: 16,
                icon: Icons.manage_accounts,
                text: '',
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
