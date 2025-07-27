
# Searchify

**A customizable Flutter search input widget with overlay dropdown, debounce, and highlight matching.**

Make your app's search experience smooth, responsive, and visually appealing with minimal setup.

---

## Features

* **Debounced async search** — avoid excessive queries while typing
* **Overlay dropdown list** — shows filtered results in a floating panel
* **Customizable styling** — flexible decorations, paddings, margins, and icons
* **Clear button** — appears only when input is non-empty and an item is selected
* **Highlight matching text** — easily highlight search substrings in results
* **Full control over item tap behavior**

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  searchify:
    path: ../searchify  # or your package source
```

Then run:

```bash
flutter pub get
```

---

## Usage Example

```dart
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

```

---

## API Overview

| Parameter          | Description                                             | Required | Default             |
| ------------------ | ------------------------------------------------------- | -------- | ------------------- |
| `searchController` | Controller for the input field                          | Yes      | —                   |
| `onSearch`         | Async callback that returns filtered results            | No       | null (no search)    |
| `itemOnTap`        | Callback when an item is tapped                         | Yes      | —                   |
| `itemBuilder`      | Widget builder for each item in the results list        | Yes      | —                   |
| `suffixIcon`       | Optional widget shown on the right inside the textfield | No       | null                |
| `separator`        | Widget shown between list items                         | No       | `SizedBox.shrink()` |
| `enabled`          | Enable or disable the text input                        | No       | `true`              |
| `isLoading`        | Show a loading indicator inside the dropdown            | No       | `false`             |
| `inSelectedMode`   | Determines if input disables after selecting an item    | No       | `true`              |
| `clearOnItemTap`   | Clears input and results when an item is tapped         | No       | `true`              |
| `style`            | `SearchifyStyle` object to customize UI styling         | No       | Default styling     |

---

## Customization

Use the `SearchifyStyle` class to customize decorations and paddings:

```dart
style: const SearchifyStyle(
  searchInputDecoration: InputDecoration(
    hintText: 'Type to search...',
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  ),
  searchBoxDecoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
  ),
  itemDecoration: BoxDecoration(
    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
  ),
  itemPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  itemMargin: EdgeInsets.symmetric(vertical: 2),
),
```

---

## Contribution & Feedback

Feel free to open issues or pull requests to improve the package.
Suggestions and star ⭐️ are always appreciated!

---

## License

MIT © Sasan Safari
 
