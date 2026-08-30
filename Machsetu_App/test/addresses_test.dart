import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:machsetu_app/core/theme/app_theme.dart';
import 'package:machsetu_app/features/profile/address_form_screen.dart';
import 'package:machsetu_app/features/profile/data/address_store.dart';

void main() {
  group('SavedAddress', () {
    const address = SavedAddress(
      id: 'ADR-1',
      label: 'Factory',
      contactName: 'Rajesh Kumar',
      contactPhone: '9876543210',
      line1: 'Plot 44',
      line2: 'Phase II',
      landmark: 'Near water tank',
      city: 'Pune',
      state: 'Maharashtra',
      zip: '411001',
      isDefault: true,
    );

    test('one-line rendering skips the blanks', () {
      const sparse = SavedAddress(
        line1: 'Plot 44',
        city: 'Pune',
        zip: '411001',
      );
      expect(sparse.oneLine, 'Plot 44, Pune, 411001');
    });

    test('multi-line puts the region and PIN on their own line', () {
      expect(address.multiLine.split('\n').length, 2);
      expect(address.multiLine, contains('Pune, Maharashtra - 411001'));
    });

    test('json round-trips every field', () {
      final copy = SavedAddress.fromJson(address.toJson());
      expect(copy.id, address.id);
      expect(copy.label, address.label);
      expect(copy.contactPhone, address.contactPhone);
      expect(copy.zip, address.zip);
      expect(copy.isDefault, isTrue);
    });

    test('a blank label falls back rather than rendering empty', () {
      final parsed = SavedAddress.fromJson(const {'label': ''});
      expect(parsed.label, 'Address');
    });
  });

  group('address form', () {
    /// The form is a ListView, so the action button starts below the fold.
    Future<void> tapSave(WidgetTester tester, String label) async {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('required fields are enforced before saving', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddressFormScreen()),
      );
      await tester.pumpAndSettle();

      await tapSave(tester, 'Save address');

      // PIN sits just above the button, so its error is already on screen.
      expect(find.text('PIN code is required'), findsOneWidget);

      // The rest are higher up; scroll back to see them.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(find.text('Address Line 1 is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('State is required'), findsOneWidget);
    });

    testWidgets('a short PIN is rejected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddressFormScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('address-label')),
        'Works',
      );
      await tester.enterText(
        find.byKey(const ValueKey('address-line1')),
        'Plot 44',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('address-zip')),
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );
      await tester.enterText(find.byKey(const ValueKey('address-zip')), '4110');
      await tester.pumpAndSettle();

      await tapSave(tester, 'Save address');

      expect(find.text('Enter a valid 6-digit PIN'), findsOneWidget);
    });

    testWidgets('an optional mobile is only checked when filled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddressFormScreen()),
      );
      await tester.pumpAndSettle();

      // Left blank: no complaint about the contact number.
      await tapSave(tester, 'Save address');
      expect(find.text('Enter a valid 10-digit mobile number'), findsNothing);

      await tester.enterText(
        find
            .widgetWithText(
              TextFormField,
              'Who receives the machine (optional)',
            )
            .last,
        'x',
      );
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    });

    testWidgets('quick labels fill the label field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddressFormScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Warehouse'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Warehouse'), findsOneWidget);
    });

    testWidgets('editing prefills every field from the address', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AddressFormScreen(
            existing: SavedAddress(
              id: 'ADR-9',
              label: 'Head Office',
              line1: 'Tower B',
              city: 'Rajkot',
              state: 'Gujarat',
              zip: '360021',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Address'), findsOneWidget);
      // Label and line 1 are the first two fields, so both are built.
      expect(find.widgetWithText(TextFormField, 'Head Office'), findsWidgets);
      expect(find.widgetWithText(TextFormField, 'Tower B'), findsOneWidget);

      // The action button says "Save changes" when editing.
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );
      expect(find.text('Save changes'), findsOneWidget);
    });
  });
}
