import 'package:flutter/material.dart';
import 'package:flutter_app_intents_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flutter App Intents Example App Tests', () {
    testWidgets('App builds and displays correct title', (tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify that the app title is displayed
      expect(find.text('Flutter App Intents Example'), findsOneWidget);

      // Verify that the home page title is displayed
      expect(find.text('Flutter App Intents Example'), findsWidgets);
    });

    testWidgets('Home page displays initial state correctly', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify initial counter value
      expect(find.text('0'), findsOneWidget);

      // Verify status is displayed
      expect(find.text('App Intents Status:'), findsOneWidget);

      // Verify Siri instructions are displayed
      expect(
        find.text('You can now use Siri to control this counter:'),
        findsOneWidget,
      );
      expect(find.text('Try these Siri commands:'), findsOneWidget);

      // Verify example commands are shown
      expect(find.textContaining('increment counter'), findsOneWidget);
      expect(find.textContaining('reset counter'), findsOneWidget);
      expect(find.textContaining('get counter value'), findsOneWidget);

      // Verify floating action button exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Manual counter increment works', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify initial counter value
      expect(find.text('0'), findsOneWidget);

      // Tap the increment button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify counter incremented
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);

      // Tap again to verify multiple increments
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('App displays status messages', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should display the status card
      expect(find.text('App Intents Status:'), findsOneWidget);

      // Should show either success message or iOS-only warning
      final statusFinder = find.descendant(
        of: find
            .ancestor(
              of: find.text('App Intents Status:'),
              matching: find.byType(Card),
            )
            .first,
        matching: find.byType(Text),
      );

      expect(statusFinder, findsWidgets);

      // Verify that some status text is displayed
      // (but don't check specific content since it depends on platform)
      final allText = find.byType(Text);
      expect(allText, findsWidgets);

      // The status card should contain some meaningful status text
      expect(statusFinder.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('App layout structure is correct', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify main structure components exist
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(Padding), findsWidgets);

      // Verify the blue instruction card exists
      final blueCards = find.byWidgetPredicate(
        (widget) => widget is Card && widget.color == Colors.blue,
      );
      expect(blueCards, findsOneWidget);
    });

    testWidgets('Counter display updates correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find the counter text widget (should be displayed prominently)
      final counterTextFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Current counter value:'),
          matching: find.byType(Column),
        ),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.style != null &&
              widget.style!.fontSize != null &&
              widget.style!.fontSize! >
                  20, // Looking for the large counter display
        ),
      );

      expect(counterTextFinder, findsOneWidget);

      // Verify it shows "0" initially
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('App handles theme correctly', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify Material Design 3 theming
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme!.useMaterial3, isTrue);
      expect(materialApp.theme!.colorScheme.primary, isNotNull);

      // Verify app bar theming
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    group('Responsive behavior', () {
      testWidgets('App works in different screen sizes', (tester) async {
        // Test with smaller screen
        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        expect(find.text('Flutter App Intents Example'), findsWidgets);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Reset screen size
        addTearDown(tester.view.reset);
      });

      testWidgets('Scrollable content works correctly', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // The main column should be scrollable if content overflows
        final columnFinder = find.byType(Column).first;
        expect(columnFinder, findsOneWidget);

        // All important elements should be visible
        expect(find.text('App Intents Status:'), findsOneWidget);
        expect(find.text('Current counter value:'), findsOneWidget);
      });
    });

    group('Error handling UI', () {
      testWidgets('Status card displays correctly', (tester) async {
        await tester.pumpWidget(const MyApp());

        // Status card should be visible
        final statusCard = find.ancestor(
          of: find.text('App Intents Status:'),
          matching: find.byType(Card),
        );
        expect(statusCard, findsOneWidget);

        // Should contain status text
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: statusCard, matching: find.byType(Text)),
          findsWidgets,
        );
      });
    });
  });
}
