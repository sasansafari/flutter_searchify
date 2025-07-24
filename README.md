
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
import 'package:searchify/searchify_refactored.dart';  // adjust import path

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(home: const SearchExample());
}

class SearchExample extends StatefulWidget {
  const SearchExample({super.key});
  @override
  State<SearchExample> createState() => _SearchExampleState();
}

class _SearchExampleState extends State<SearchExample> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _items = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

  Future<List<String>> _searchItems(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 300)); // debounce simulation
    return _items
        .where((item) => item.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index = lcText.indexOf(lcQuery);
    while (index >= 0) {
      if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(backgroundColor: Colors.yellowAccent, fontWeight: FontWeight.bold)));
      start = index + query.length;
      index = lcText.indexOf(lcQuery, start);
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Searchify Demo')),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Searchify<String>(
            searchController: _controller,
            onSearch: _searchItems,
            itemOnTap: (item) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $item'))),
            itemBuilder: (item) => _highlightMatch(item, _controller.text),
            suffixIcon: const Icon(Icons.search),
            style: const SearchifyStyle(
              searchBoxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              listBoxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              itemPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
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
 
