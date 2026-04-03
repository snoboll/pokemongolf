import 'package:flutter_test/flutter_test.dart';

import 'package:pokemon_golf/app.dart';

void main() {
  testWidgets('app shows home tab by default and can switch tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PokemonGolfApp());

    expect(find.text('Pokemon Golf'), findsOneWidget);
    expect(find.text('18 Holes'), findsOneWidget);
    expect(find.text('9 Holes'), findsOneWidget);

    expect(find.text('Pokedex'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scorecards'), findsOneWidget);

    await tester.tap(find.text('Pokedex'));
    await tester.pumpAndSettle();

    expect(find.textContaining('/ 151'), findsOneWidget);

    await tester.tap(find.text('Scorecards'));
    await tester.pumpAndSettle();

    expect(find.text('No rounds yet'), findsOneWidget);
  });
}
