import 'package:flutter/material.dart';

class SearchScreen extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results here based on the query
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement suggestions based on the current query
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        title: Text('Suggestion ${index + 1} for $query'),
        onTap: () {
          query = 'Suggestion ${index + 1} for $query';
          showResults(context);
        },
      ),
    );
  }
}
