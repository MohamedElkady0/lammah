import 'package:flutter/material.dart';
import 'package:lammah/core/utils/chat_string.dart';

class SearchApp extends StatefulWidget {
  const SearchApp({super.key});

  @override
  State<SearchApp> createState() => _SearchAppState();
}

class _SearchAppState extends State<SearchApp> {
  final SearchController _searchController = SearchController();

  final List<String> _searchHistory = [];

  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();

    _currentSuggestions = List.from(_searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barBackgroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.tertiary.withAlpha(150),
      ),
      searchController: _searchController,
      barHintText: ChatString.search,

      barTrailing: [IconButton(icon: Icon(Icons.mic), onPressed: () {})],
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final String query = controller.text.toLowerCase();
        if (query.isEmpty) {
          _currentSuggestions = List.from(_searchHistory);
        } else {
          _currentSuggestions = _searchHistory.where((item) {
            return item.toLowerCase().contains(query);
          }).toList();
        }

        if (_currentSuggestions.isEmpty && query.isNotEmpty) {
          return [const ListTile(title: Text(ChatString.noItems))];
        }

        return List<Widget>.generate(_currentSuggestions.length, (int index) {
          final String item = _currentSuggestions[index];
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تم اختيار: $item')));
              });
            },
          );
        });
      },
    );
  }
}
