import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:machsetu_app/core/services/catalogue_service.dart';
import 'package:machsetu_app/core/theme/app_theme.dart';
import 'fixtures/demo_machines.dart';
import 'package:machsetu_app/features/search/data/recent_searches.dart';
import 'package:machsetu_app/features/search/search_screen.dart';

void main() {
  final store = RecentSearchStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
    CatalogueService.instance.seed(DemoMachines.all);
  });

  group('RecentSearchStore', () {
    test('keeps newest first', () async {
      await store.record('lathe');
      await store.record('haas');
      expect(store.terms, ['haas', 'lathe']);
    });

    test('a repeat moves to the top instead of duplicating', () async {
      await store.record('lathe');
      await store.record('haas');
      await store.record('lathe');
      expect(store.terms, ['lathe', 'haas']);
    });

    test('is case-insensitive when de-duplicating', () async {
      await store.record('Haas');
      await store.record('haas');
      expect(store.terms.length, 1);
      expect(store.terms.first, 'haas');
    });

    test('caps the history at four', () async {
      for (final term in ['one', 'two', 'three', 'four', 'five', 'six']) {
        await store.record(term);
      }
      expect(store.terms.length, RecentSearchStore.limit);
      expect(store.terms, ['six', 'five', 'four', 'three']);
    });

    test('ignores stray keystrokes', () async {
      await store.record('a');
      await store.record('ab');
      await store.record('   ');
      expect(store.terms, isEmpty);

      await store.record('abc');
      expect(store.terms, ['abc']);
    });

    test('a single term can be removed', () async {
      await store.record('lathe');
      await store.record('haas');
      await store.remove('lathe');
      expect(store.terms, ['haas']);
    });

    test('clear empties the history', () async {
      await store.record('lathe');
      await store.clear();
      expect(store.terms, isEmpty);
    });

    test('survives a restart', () async {
      await store.record('grinder');
      // A fresh load reads what was persisted.
      store.resetForTest();
      await store.load();
      expect(store.terms, ['grinder']);
    });
  });

  group('search screen', () {
    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SearchScreen()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('recents stay hidden until the box is focused', (tester) async {
      await store.record('mazak');
      await open(tester);

      expect(find.text('RECENT SEARCHES'), findsNothing);

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      expect(find.text('RECENT SEARCHES'), findsOneWidget);
      expect(find.text('mazak'), findsOneWidget);
    });

    testWidgets('nothing shows on focus when there is no history', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      expect(find.text('RECENT SEARCHES'), findsNothing);
    });

    testWidgets('submitting a query records it', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).first, 'haas');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(store.terms, contains('haas'));
    });

    testWidgets('tapping a recent runs it and closes the panel', (
      tester,
    ) async {
      await store.record('doosan');
      await open(tester);

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('doosan'));
      await tester.pumpAndSettle();

      // The query is applied and the panel is closed again.
      expect(find.text('RECENT SEARCHES'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'doosan',
      );
    });

    testWidgets('a recent can be removed from the panel', (tester) async {
      await store.record('lathe');
      await store.record('grinder');
      await open(tester);

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.text('lathe'), findsOneWidget);

      // Each chip carries its own close icon; the newest row is first, so
      // "lathe" is the second one.
      final closes = find.byIcon(Icons.close);
      expect(closes, findsNWidgets(2));
      await tester.tap(closes.last);
      await tester.pumpAndSettle();

      expect(store.terms, ['grinder']);
    });
  });
}
