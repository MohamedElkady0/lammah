import 'package:flutter/material.dart';

class SearchShop extends StatelessWidget {
  const SearchShop({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barLeading: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              size: 25,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.camera_alt,
              size: 25,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      barBackgroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.primary.withAlpha(50),
      ),
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // Return a list of widgets as suggestions, for example:
        return [ListTile(title: Text('No suggestions available'))];
      },
    );
  }
}
