import 'package:flutter/material.dart';
import 'package:searchify/searchify.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Searchify Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SearchExample(),
    );
  }
}

class SearchExample extends StatefulWidget {
  const SearchExample({super.key});

  @override
  State<SearchExample> createState() => _SearchExampleState();
}

class _SearchExampleState extends State<SearchExample> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _cities = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
  ];

  Future<List<String>> _searchCities(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 300)); // شبیه‌سازی تاخیر
    return _cities
        .where((city) => city.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  // برای نمایش متن جستجو شده به صورت هایلایت
  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;
    int index = lcText.indexOf(lcQuery);

    while (index >= 0) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
      index = lcText.indexOf(lcQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Searchify Example')),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Searchify<String>(
            searchController: _controller,
            onSearch: _searchCities,
            itemOnTap: (city) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected: $city')));
            },
            itemBuilder: (city) {
              return _highlightMatch(city, _controller.text);
            },
            suffixIcon: const Icon(Icons.search),
            style: const SearchifyStyle(
              searchBoxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              listBoxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              itemPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemMargin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              searchInputPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              searchInputMargin: EdgeInsets.all(10),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blue[50],
    );
  }
}
