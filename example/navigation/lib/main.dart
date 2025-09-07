import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation App Intents Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NavigationHomePage(),
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
        '/search': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          return SearchPage(query: args?['query'] ?? '');
        },
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class NavigationHomePage extends StatefulWidget {
  const NavigationHomePage({super.key});

  @override
  State<NavigationHomePage> createState() => _NavigationHomePageState();
}

class _NavigationHomePageState extends State<NavigationHomePage> {
  final FlutterAppIntentsClient _client = FlutterAppIntentsClient.instance;
  String _status = 'Initializing...';
  List<AppIntent> _registeredIntents = [];

  @override
  void initState() {
    super.initState();
    _setupNavigationIntents();
  }

  Future<void> _setupNavigationIntents() async {
    if (!Platform.isIOS) {
      setState(() {
        _status = 'App Intents are only supported on iOS';
      });

      return;
    }

    try {
      // Create navigation intents
      final openProfileIntent = AppIntentBuilder()
          .identifier('open_profile')
          .title('Open Profile')
          .description('Navigate to user profile page')
          .phrases([
            'Open Profile',
            'Show Profile',
            'Go to Profile',
            'View Profile',
            'Display Profile',
          ])
          .parameter(
            const AppIntentParameter(
              name: 'userId',
              title: 'User ID',
              type: AppIntentParameterType.string,
              isOptional: true,
              defaultValue: 'current',
            ),
          )
          .build();

      final openChatIntent = AppIntentBuilder()
          .identifier('open_chat')
          .title('Open Chat')
          .description('Open chat with a contact')
          .phrases([
            'Open Chat',
            'Start Chat',
            'Begin Chat',
            'Message Someone',
            'Send Message',
          ])
          .parameter(
            const AppIntentParameter(
              name: 'contactName',
              title: 'Contact Name',
              type: AppIntentParameterType.string,
            ),
          )
          .build();

      final searchContentIntent = AppIntentBuilder()
          .identifier('search_content')
          .title('Search Content')
          .description('Search for content in the app')
          .phrases([
            'Search Content',
            'Find Content',
            'Look for Content',
            'Search App',
            'Find Something',
          ])
          .parameter(
            const AppIntentParameter(
              name: 'query',
              title: 'Search Query',
              type: AppIntentParameterType.string,
            ),
          )
          .build();

      final openSettingsIntent = AppIntentBuilder()
          .identifier('open_settings')
          .title('Open Settings')
          .description('Navigate to app settings')
          .phrases([
            'Open Settings',
            'Show Settings',
            'Go to Settings',
            'App Settings',
            'Preferences',
          ])
          .build();

      // Register all navigation intents
      await _client.registerIntents({
        openProfileIntent: _handleOpenProfileIntent,
        openChatIntent: _handleOpenChatIntent,
        searchContentIntent: _handleSearchContentIntent,
        openSettingsIntent: _handleOpenSettingsIntent,
      });

      await _client.updateShortcuts();
      _registeredIntents = await _client.getRegisteredIntents();

      setState(() {
        _status = 'Navigation intents registered successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<AppIntentResult> _handleOpenProfileIntent(
    Map<String, dynamic> parameters,
  ) async {
    final userId = parameters['userId'] as String? ?? 'current';

    if (mounted) {
      Navigator.of(
        context,
      ).pushNamed('/profile', arguments: {'userId': userId});
    }

    await _client.donateIntent('open_profile', parameters);

    return AppIntentResult.successful(
      value: 'Opening profile for user $userId',
      needsToContinueInApp: true,
    );
  }

  Future<AppIntentResult> _handleOpenChatIntent(
    Map<String, dynamic> parameters,
  ) async {
    final contactName = parameters['contactName'] as String;

    if (mounted) {
      Navigator.of(
        context,
      ).pushNamed('/chat', arguments: {'contactName': contactName});
    }

    await _client.donateIntent('open_chat', parameters);

    return AppIntentResult.successful(
      value: 'Opening chat with $contactName',
      needsToContinueInApp: true,
    );
  }

  Future<AppIntentResult> _handleSearchContentIntent(
    Map<String, dynamic> parameters,
  ) async {
    final query = parameters['query'] as String;

    if (mounted) {
      Navigator.of(context).pushNamed('/search', arguments: {'query': query});
    }

    await _client.donateIntent('search_content', parameters);

    return AppIntentResult.successful(
      value: 'Searching for "$query"',
      needsToContinueInApp: true,
    );
  }

  Future<AppIntentResult> _handleOpenSettingsIntent(
    Map<String, dynamic> parameters,
  ) async {
    if (mounted) {
      Navigator.of(context).pushNamed('/settings');
    }

    await _client.donateIntent('open_settings', parameters);

    return AppIntentResult.successful(
      value: 'Opening settings',
      needsToContinueInApp: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Navigation App Intents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'App Intents Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Try these Siri commands:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• "Show Profile" or "View Profile"\n'
                      '• "Start Chat contactName Alice" or "Message Someone"\n'
                      '• "Find Content query photos" or "Search App"\n'
                      '• "App Settings" or "Preferences"\n'
                      '• Try multiple natural variations!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Manual Navigation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _handleOpenProfileIntent({'userId': 'demo'}),
                  child: const Text('Open Profile'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _handleOpenChatIntent({'contactName': 'Demo User'}),
                  child: const Text('Open Chat'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _handleSearchContentIntent({'query': 'test'}),
                  child: const Text('Search Content'),
                ),
                ElevatedButton(
                  onPressed: () => _handleOpenSettingsIntent({}),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_registeredIntents.isNotEmpty) ...[
              const Text(
                'Registered Navigation Intents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _registeredIntents.length,
                  itemBuilder: (context, index) {
                    final intent = _registeredIntents[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.navigation),
                        title: Text(intent.title),
                        subtitle: Text(intent.description),
                        trailing: Chip(label: Text(intent.identifier)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// MARK: - Navigation Pages

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Profile: $userId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '🎯 Opened via App Intent!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String contactName;

  const ChatPage({required this.contactName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $contactName'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              'Chat with: $contactName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.purple,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '💬 Opened via Siri Voice Command!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final String query;

  const SearchPage({required this.query, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'Searching for: "$query"',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.orange,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '🔍 Searched via Voice Command!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'App Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '⚙️ Opened via Navigation Intent!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
