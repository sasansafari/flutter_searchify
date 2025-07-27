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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Searchify Example')),
  //     body: Center(
  //       child: SizedBox(
  //         width: MediaQuery.sizeOf(context).width * .7,
  //         child: Searchify<String>(
  //           searchController: _controller,
  //           onSearch: _searchCities,
  //           itemOnTap: (city) {
  //             ScaffoldMessenger.of(
  //               context,
  //             ).showSnackBar(SnackBar(content: Text('Selected: $city')));
  //           },
  //           suffixIcon: const Icon(Icons.search),
  //           overlayWidth: 320,
  //         ),
  //       ),
  //     ),
  //     backgroundColor: Colors.blue[50],
  //   );
  // }
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('🎁 Searchify Demo Form'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find your city!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Searchify<String>(
                    searchController: _controller,
                    onSearch: _searchCities,
                    itemOnTap: (city) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $city')),
                      );
                    },
                    suffixIcon: const Icon(Icons.search),
                    overlayWidth: 460,
                    // itemBuilder: (city) => _highlightOverride(city, _controller.text),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _accepted,
                        onChanged: (value) {
                          setState(() => _accepted = value ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text('I agree to the terms and conditions.'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _accepted
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Form submitted!')),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
