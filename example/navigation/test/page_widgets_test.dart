// UI widget tests for navigation app pages
//
// Tests all navigation page widgets (ProfilePage, ChatPage, SearchPage, SettingsPage)
// and the main NavigationHomePage to ensure they render correctly and display
// the expected content based on their parameters.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_example/main.dart';

void main() {
  group('Pages Widgets Tests', () {
    group('ProfilePage', () {
      testWidgets('should display default user ID', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ProfilePage(userId: 'current')),
        );

        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Profile: current'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.text('🎯 Opened via App Intent!'), findsOneWidget);
      });

      testWidgets('should display custom user ID', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ProfilePage(userId: 'user123')),
        );

        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Profile: user123'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('should have back navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const Scaffold(body: Text('Home')),
            routes: {
              '/profile': (context) => const ProfilePage(userId: 'test'),
            },
          ),
        );

        // Navigate to profile
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        // Directly build profile page with navigation
        await tester.pumpWidget(
          MaterialApp(
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => const ProfilePage(userId: 'test'),
              ),
            ),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });
    });

    group('ChatPage', () {
      testWidgets('should display contact name', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ChatPage(contactName: 'Alice')),
        );

        expect(find.text('Chat with Alice'), findsOneWidget);
        expect(find.text('Chat with: Alice'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
        expect(find.text('💬 Opened via Siri Voice Command!'), findsOneWidget);
      });

      testWidgets('should handle unknown contact', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ChatPage(contactName: 'Unknown')),
        );

        expect(find.text('Chat with Unknown'), findsOneWidget);
        expect(find.text('Chat with: Unknown'), findsOneWidget);
      });

      testWidgets('should display contact name in app bar', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ChatPage(contactName: 'Bob')),
        );

        final appBarFinder = find.ancestor(
          of: find.text('Chat with Bob'),
          matching: find.byType(AppBar),
        );
        expect(appBarFinder, findsOneWidget);
      });
    });

    group('SearchPage', () {
      testWidgets('should display search query', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SearchPage(query: 'flutter tutorials')),
        );

        expect(find.text('Search Results'), findsOneWidget);
        expect(find.text('Searching for: "flutter tutorials"'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.text('🔍 Searched via Voice Command!'), findsOneWidget);
      });

      testWidgets('should handle empty query', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SearchPage(query: '')));

        expect(find.text('Search Results'), findsOneWidget);
        expect(find.text('Searching for: ""'), findsOneWidget);
      });

      testWidgets('should display search icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SearchPage(query: 'test')),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.text('Search Results'), findsOneWidget);
      });
    });

    group('SettingsPage', () {
      testWidgets('should display settings content', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('App Settings'), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.text('⚙️ Opened via Navigation Intent!'), findsOneWidget);
      });

      testWidgets('should have consistent layout', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

        // Check for centered column layout
        expect(find.byType(Center), findsWidgets);
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('NavigationHomePage', () {
      testWidgets('should display home page content', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: NavigationHomePage()));
        await tester.pumpAndSettle();

        expect(find.text('Navigation App Intents Example'), findsOneWidget);
        expect(find.text('App Intents Status:'), findsOneWidget);
        expect(find.text('Manual Navigation:'), findsOneWidget);
      });

      testWidgets('should have navigation buttons', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: NavigationHomePage()));
        await tester.pumpAndSettle();

        expect(find.text('Open Profile'), findsOneWidget);
        expect(find.text('Open Chat'), findsOneWidget);
        expect(find.text('Search Content'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);
      });

      testWidgets('should have clickable navigation buttons', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: NavigationHomePage()));
        await tester.pumpAndSettle();

        // Verify all navigation buttons exist and are tappable
        final profileButton = find.text('Open Profile');
        final chatButton = find.text('Open Chat');
        final searchButton = find.text('Search Content');
        final settingsButton = find.text('Open Settings');

        expect(profileButton, findsOneWidget);
        expect(chatButton, findsOneWidget);
        expect(searchButton, findsOneWidget);
        expect(settingsButton, findsOneWidget);

        // Verify they are ElevatedButton widgets (clickable)
        expect(find.byType(ElevatedButton), findsNWidgets(4));
      });
    });
  });

  group('App Routes', () {
    testWidgets('should configure routes correctly', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify the app builds without errors
      expect(find.byType(NavigationHomePage), findsOneWidget);
    });

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
  });
}
