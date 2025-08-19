import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lammah/core/utils/string_app.dart';

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
            rippleColor: Theme.of(
              context,
            ).colorScheme.onPrimary, // tab button ripple color when pressed
            hoverColor: Theme.of(
              context,
            ).colorScheme.tertiary, // tab button hover color
            haptic: true, // haptic feedback
            tabBorderRadius: 15,
            tabActiveBorder: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1,
            ), // tab button border
            tabBorder: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              width: 1,
            ), // tab button border
            tabShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                blurRadius: 8,
              ),
            ], // tab button shadow
            curve: Curves.easeOutExpo, // tab animation curves
            // tab animation duration
            gap: 8, // the tab button gap between icon and text
            color: Theme.of(
              context,
            ).colorScheme.onPrimary, // unselected icon color
            activeColor: Theme.of(
              context,
            ).colorScheme.primary, // selected icon and text color
            iconSize: 24, // tab button icon size
            tabBackgroundColor: Theme.of(
              context,
            ).colorScheme.onPrimary, // selected tab background color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 100),

            tabs: [
              GButton(
                icon: FontAwesomeIcons.house,
                text: StringApp.chats,
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
              GButton(
                icon: FontAwesomeIcons.store,
                text: StringApp.store,
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),
              GButton(
                icon: FontAwesomeIcons.newspaper,
                text: StringApp.news,
                backgroundGradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ],
                ),
              ),

              GButton(
                icon: FontAwesomeIcons.film,
                text: StringApp.enjoyment,
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
