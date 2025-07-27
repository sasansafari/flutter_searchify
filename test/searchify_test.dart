import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchify/searchify.dart';

void main() {
  testWidgets('Searchify renders and responds to input', (
    WidgetTester tester,
  ) async {
    final sampleData = ['Tehran', 'Tabriz', 'Shiraz'];

    Future<List<String>> searchCity(String keyword) async {
      return sampleData
          .where((city) => city.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Searchify<String>(
            searchController: controller,
            onSearch: searchCity,
            itemOnTap: (_) {},
            itemBuilder: (item) => Text(item),
            suffixIcon: Icon(Icons.search),
            focusNode: FocusNode(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'teh');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Tehran'), findsOneWidget);
    expect(find.text('Tabriz'), findsNothing);
  });
}
