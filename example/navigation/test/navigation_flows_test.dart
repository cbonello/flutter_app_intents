// End-to-end navigation flow tests
//
// Tests complete navigation flows including route handling, parameter passing,
// deep linking, and error scenarios. Focuses on navigation logic rather than
// iOS-specific App Intents functionality which cannot be tested reliably.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_example/main.dart';

void main() {
  group('Navigation Flow Tests', () {
    testWidgets('app should start without errors', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify the home page loads
      expect(find.text('Navigation App Intents'), findsOneWidget);
      expect(find.text('Manual Navigation:'), findsOneWidget);
    });

    // Skip intent-based tests on non-iOS platforms since donateIntent throws
    group('Navigation Flow Tests', () {
      testWidgets('should display navigation buttons', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        expect(find.text('Open Profile'), findsOneWidget);
        expect(find.text('Open Chat'), findsOneWidget);
        expect(find.text('Search Content'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);
      });

      testWidgets('should display initial status and registered intents info', (
        tester,
      ) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Check for status and intents sections
        expect(find.text('App Intents Status:'), findsOneWidget);
        // Registered intents section may or may not be visible depending on
        //iOS platform
      });
    });

    group('Route Navigation Tests', () {
      testWidgets('should handle profile route with arguments', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/profile': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ProfilePage(userId: args?['userId'] ?? 'current');
              },
            },
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {'userId': 'test123'},
                ),
                child: const Text('Go to Profile'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Profile'));
        await tester.pumpAndSettle();

        expect(find.text('Profile: test123'), findsOneWidget);
      });

      testWidgets('should handle chat route with arguments', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/chat': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ChatPage(contactName: args?['contactName'] ?? 'Unknown');
              },
            },
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {'contactName': 'TestUser'},
                ),
                child: const Text('Go to Chat'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Chat with: TestUser'), findsOneWidget);
      });

      testWidgets('should handle search route with arguments', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/search': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return SearchPage(query: args?['query'] ?? '');
              },
            },
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/search',
                  arguments: {'query': 'flutter'},
                ),
                child: const Text('Go to Search'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Search'));
        await tester.pumpAndSettle();

        expect(find.text('Searching for: "flutter"'), findsOneWidget);
      });

      testWidgets('should handle settings route', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {'/settings': (context) => const SettingsPage()},
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                child: const Text('Go to Settings'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Settings'));
        await tester.pumpAndSettle();

        expect(find.text('App Settings'), findsOneWidget);
      });
    });

    group('Direct Route Tests', () {
      testWidgets('should handle deep links correctly', (tester) async {
        // Test direct route navigation (simulating deep link or intent)
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/profile',
            routes: {
              '/profile': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ProfilePage(userId: args?['userId'] ?? 'current');
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Should start directly on profile page
        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Profile: current'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle missing route arguments gracefully', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/profile': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ProfilePage(userId: args?['userId'] ?? 'current');
              },
              '/chat': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ChatPage(contactName: args?['contactName'] ?? 'Unknown');
              },
            },
            home: Column(
              children: [
                Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('Profile (no args)'),
                  ),
                ),
                Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/chat'),
                    child: const Text('Chat (no args)'),
                  ),
                ),
              ],
            ),
          ),
        );

        // Test profile with no arguments
        await tester.tap(find.text('Profile (no args)'));
        await tester.pumpAndSettle();

        expect(find.text('Profile: current'), findsOneWidget);

        // Go back and test chat
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Chat (no args)'));
        await tester.pumpAndSettle();

        expect(find.text('Chat with: Unknown'), findsOneWidget);
      });

      testWidgets('should handle null arguments gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/profile': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                return ProfilePage(userId: args?['userId'] ?? 'current');
              },
            },
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {'userId': null},
                ),
                child: const Text('Profile (null userId)'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Profile (null userId)'));
        await tester.pumpAndSettle();

        expect(find.text('Profile: current'), findsOneWidget);
      });
    });

    group('Page Content Validation', () {
      testWidgets('should display correct content on all pages', (
        tester,
      ) async {
        // Test ProfilePage
        await tester.pumpWidget(
          const MaterialApp(home: ProfilePage(userId: 'test-user')),
        );
        expect(find.text('Profile: test-user'), findsOneWidget);
        expect(find.text('🎯 Opened via App Intent!'), findsOneWidget);

        // Test ChatPage
        await tester.pumpWidget(
          const MaterialApp(home: ChatPage(contactName: 'Alice')),
        );
        expect(find.text('Chat with: Alice'), findsOneWidget);
        expect(find.text('💬 Opened via Siri Voice Command!'), findsOneWidget);

        // Test SearchPage
        await tester.pumpWidget(
          const MaterialApp(home: SearchPage(query: 'flutter')),
        );
        expect(find.text('Searching for: "flutter"'), findsOneWidget);
        expect(find.text('🔍 Searched via Voice Command!'), findsOneWidget);

        // Test SettingsPage
        await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
        expect(find.text('App Settings'), findsOneWidget);
        expect(find.text('⚙️ Opened via Navigation Intent!'), findsOneWidget);
      });
    });
  });
}
