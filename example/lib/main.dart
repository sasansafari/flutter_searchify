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
      title: 'Searchify Example',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SearchifyDemo(),
    );
  }
}

class SearchifyDemo extends StatefulWidget {
  const SearchifyDemo({super.key});

  @override
  State<SearchifyDemo> createState() => _SearchifyDemoState();
}

class _SearchifyDemoState extends State<SearchifyDemo> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedCity = '';

  // لیست تستی برای جستجو
  final List<String> _cities = [
    'Tehran',
    'Tabriz',
    'Shiraz',
    'Mashhad',
    'Esfahan',
    'Ahvaz',
    'Rasht',
    'Kerman',
    'Kermanshah',
  ];

  Future<List<String>> _searchCity(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200)); // simulate latency
    return _cities
        .where((city) => city.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Searchify Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Searchify<String>(
              searchController: _controller,
              onSearch: _searchCity,
              itemBuilder: (item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
              itemOnTap: (item) {
                setState(() => _selectedCity = item);
              },
              suffixIcon: const Icon(Icons.search, size: 20),
              focusNode: _focusNode,
              listWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            const SizedBox(height: 24),
            Text(
              _selectedCity.isEmpty
                  ? 'Please select a city'
                  : 'Selected: $_selectedCity',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
