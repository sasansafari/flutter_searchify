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
    'Tehran',
    'Mashhad',
    'Isfahan',
    'Karaj',
    'Shiraz',
    'Tabriz',
    'Qom',
    'Ahvaz',
    'Kermanshah',
    'Urmia',
    'Rasht',
    'Zahedan',
    'Hamadan',
    'Arak',
    'Yazd',
    'Bandar Abbas',
    'Kerman',
    'Qazvin',
    'Zanjan',
    'Sanandaj',
    'Khorramabad',
    'Bojnord',
    'Sari',
    'Gorgan',
    'Bushehr',
    'Dezful',
    'Shahr-e Kord',
    'Birjand',
    'Ilam',
    'Semnan',
  ];

  Future<List<String>> _searchCities(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cities
        .where((city) => city.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  // Widget _highlightOverride(String text, String query) {
  //   if (query.isEmpty) return Text(text);
  //   final lcText = text.toLowerCase();
  //   final lcQuery = query.toLowerCase();

  //   final spans = <TextSpan>[];
  //   int start = 0;
  //   int index = lcText.indexOf(lcQuery);

  //   while (index >= 0) {
  //     if (index > start) {
  //       spans.add(TextSpan(text: text.substring(start, index)));
  //     }
  //     spans.add(
  //       TextSpan(
  //         text: text.substring(index, index + query.length),
  //         style: const TextStyle(
  //           backgroundColor: Colors.lightBlueAccent,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //     );
  //     start = index + query.length;
  //     index = lcText.indexOf(lcQuery, start);
  //   }

  //   if (start < text.length) {
  //     spans.add(TextSpan(text: text.substring(start)));
  //   }

  //   return RichText(
  //     text: TextSpan(
  //       style: const TextStyle(color: Colors.black),
  //       children: spans,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Searchify Example')),
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .7,
          child: Searchify<String>(
            searchController: _controller,
            onSearch: _searchCities,
            itemOnTap: (city) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected: $city')));
            },

            // itemBuilder: (city) {
            //   return _highlightOverride(city, _controller.text);
            // },
            suffixIcon: const Icon(Icons.search),

            overlayWidth: 320,
          ),
        ),
      ),
      backgroundColor: Colors.blue[50],
    );
  }
}
