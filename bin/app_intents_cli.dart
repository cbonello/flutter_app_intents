#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_app_intents/src/generator/cli_runner.dart';

/// Main entry point for the code generator CLI
///
/// Usage:
///   dart run flutter_app_intents:generate [options]
///
/// Options:
///   `--platform=<ios,android>`  Target platforms (comma-separated).
///   --watch                   Watch for changes and regenerate.
///   --help                    Show usage information.
Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'platform',
      abbr: 'p',
      help: 'Target platform(s) for code generation (comma-separated)',
    )
    ..addOption(
      'main-activity',
      help: 'Android main activity class name '
          '(e.g., MainActivity, SplashActivity)',
    )
    ..addFlag(
      'watch',
      abbr: 'w',
      help: 'Watch for file changes and regenerate automatically',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
    );

  ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } on FormatException catch (e) {
    stdout.writeln('Error: ${e.message}\n');
    _printUsage(parser);
    exit(1);
  }

  if (argResults['help'] as bool) {
    _printUsage(parser);
    exit(0);
  }

  final platformArg = argResults['platform'] as String?;
  final mainActivity = argResults['main-activity'] as String?;
  final watch = argResults['watch'] as bool;

  final runner = CliRunner();

  try {
    await runner.run(
      platform: platformArg,
      mainActivity: mainActivity,
      watch: watch,
    );
  } on Exception catch (e) {
    stdout.writeln('❌ Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stdout
    ..writeln('flutter_app_intents code generator')
    ..writeln()
    ..writeln('Usage: dart run flutter_app_intents:generate [options]')
    ..writeln()
    ..writeln('Options:')
    ..writeln(parser.usage)
    ..writeln()
    ..writeln('Examples:')
    ..writeln('  # Generate for Android (default in v1.0.0)')
    ..writeln('  dart run flutter_app_intents:generate')
    ..writeln()
    ..writeln('  # Generate for specific platform')
    ..writeln('  dart run flutter_app_intents:generate --platform=android')
    ..writeln()
    ..writeln('  # Generate for multiple platforms')
    ..writeln('  dart run flutter_app_intents:generate --platform=ios,android')
    ..writeln()
    ..writeln('  # Specify custom main activity (Android)')
    ..writeln(
      '  dart run flutter_app_intents:generate --main-activity=SplashActivity',
    )
    ..writeln()
    ..writeln('  # Watch mode (auto-regenerate on file changes)')
    ..writeln('  dart run flutter_app_intents:generate --watch');
}
