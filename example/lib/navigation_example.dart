import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

/// Example showing how to handle navigation intents with Flutter App Intents
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  final FlutterAppIntentsClient _client = FlutterAppIntentsClient.instance;
  
  @override
  void initState() {
    super.initState();
    _setupNavigationIntents();
  }

  /// Setup navigation-focused App Intents
  Future<void> _setupNavigationIntents() async {
    try {
      // Open Profile Intent
      final openProfileIntent = AppIntentBuilder()
          .identifier('open_profile')
          .title('Open Profile')
          .description('Navigate to user profile page')
          .parameter(const AppIntentParameter(
            name: 'userId',
            title: 'User ID',
            type: AppIntentParameterType.string,
            isOptional: true,
            defaultValue: 'current',
          ))
          .build();

      // Open Chat Intent  
      final openChatIntent = AppIntentBuilder()
          .identifier('open_chat')
          .title('Open Chat')
          .description('Open chat conversation with a contact')
          .parameter(const AppIntentParameter(
            name: 'contactName',
            title: 'Contact Name',
            type: AppIntentParameterType.string,
            isOptional: false,
          ))
          .build();

      // Search Content Intent
      final searchContentIntent = AppIntentBuilder()
          .identifier('search_content')
          .title('Search Content')
          .description('Search for content within the app')
          .parameter(const AppIntentParameter(
            name: 'query',
            title: 'Search Query',
            type: AppIntentParameterType.string,
            isOptional: false,
          ))
          .build();

      // Register all navigation intents
      await _client.registerIntents({
        openProfileIntent: _handleOpenProfileIntent,
        openChatIntent: _handleOpenChatIntent,
        searchContentIntent: _handleSearchContentIntent,
      });

      print('✅ Navigation intents registered successfully');
    } catch (e) {
      print('❌ Failed to register navigation intents: $e');
    }
  }

  /// Handle opening user profile
  Future<AppIntentResult> _handleOpenProfileIntent(
    Map<String, dynamic> parameters,
  ) async {
    final userId = parameters['userId'] as String? ?? 'current';
    
    print('🧭 Navigating to profile: $userId');
    
    // Navigate to profile page
    if (mounted) {
      Navigator.of(context).pushNamed(
        '/profile',
        arguments: {'userId': userId},
      );
    }

    // Donate intent for Siri learning
    await _client.donateIntent('open_profile', parameters);

    return AppIntentResult.successful(
      value: 'Opening profile for user $userId',
      needsToContinueInApp: true, // Critical: tells iOS to focus the app
    );
  }

  /// Handle opening chat with contact
  Future<AppIntentResult> _handleOpenChatIntent(
    Map<String, dynamic> parameters,
  ) async {
    final contactName = parameters['contactName'] as String;
    
    print('💬 Opening chat with: $contactName');
    
    // Navigate to chat page
    if (mounted) {
      Navigator.of(context).pushNamed(
        '/chat',
        arguments: {'contactName': contactName},
      );
    }

    // Donate intent
    await _client.donateIntent('open_chat', parameters);

    return AppIntentResult.successful(
      value: 'Opening chat with $contactName',
      needsToContinueInApp: true,
    );
  }

  /// Handle content search
  Future<AppIntentResult> _handleSearchContentIntent(
    Map<String, dynamic> parameters,
  ) async {
    final query = parameters['query'] as String;
    
    print('🔍 Searching for: $query');
    
    // Navigate to search results page
    if (mounted) {
      Navigator.of(context).pushNamed(
        '/search',
        arguments: {'query': query},
      );
    }

    // Donate intent
    await _client.donateIntent('search_content', parameters);

    return AppIntentResult.successful(
      value: 'Searching for "$query"',
      needsToContinueInApp: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Intents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Try these Siri commands for navigation:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• "Open my profile in flutter app intents example"\n'
                      '• "Chat with Alice using flutter app intents example"\n'
                      '• "Search for photos in flutter app intents example"',
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
            ElevatedButton(
              onPressed: () => _handleOpenProfileIntent({'userId': 'demo'}),
              child: const Text('Open Profile'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _handleOpenChatIntent({'contactName': 'Demo User'}),
              child: const Text('Open Chat'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _handleSearchContentIntent({'query': 'test'}),
              child: const Text('Search Content'),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Example navigation pages

class ProfilePage extends StatelessWidget {
  final String userId;
  
  const ProfilePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            Text('Profile for: $userId', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Text('📱 Opened via App Intent!', style: TextStyle(color: Colors.green)),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 64),
            const SizedBox(height: 16),
            Text('Chatting with: $contactName', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Text('💬 Opened via Siri!', style: TextStyle(color: Colors.blue)),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64),
            const SizedBox(height: 16),
            Text('Searching for: "$query"', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Text('🔍 Searched via Voice Command!', style: TextStyle(color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}