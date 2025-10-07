import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:path/path.dart' as p;

/// Extracts intent definitions from Dart code using AST analysis.
///
/// Supports two patterns:
/// 1. Method chaining: `AppIntentBuilder().identifier('x').build()`
/// 2. Variable assignment:
///    `final builder = AppIntentBuilder(); builder.identifier('x');`
class IntentExtractor {
  /// The number of files scanned during the last extraction.
  int filesScanned = 0;

  /// A list of non-fatal warnings that occurred during extraction.
  final List<String> warnings = [];

  /// Scans all `.dart` files in a given [dirPath] and extracts all
  /// `AppIntentBuilder` definitions.
  Future<List<ExtractedIntent>> extractFromDirectory(String dirPath) async {
    filesScanned = 0;
    warnings.clear();
    final intents = <ExtractedIntent>[];

    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      throw Exception(
        'Directory not found: ${dir.path}. The generator expected this '
        'directory to exist.',
      );
    }

    // Find all Dart files recursively
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    if (files.isEmpty) return [];

    // Find Dart SDK path
    final sdkPath = _findDartSdkPath();

    // Create analysis context with explicit SDK path
    final collection = AnalysisContextCollection(
      includedPaths: [dir.absolute.path],
      sdkPath: sdkPath,
    );

    for (final file in files) {
      try {
        filesScanned++;
        final filePath = p.normalize(file.absolute.path);

        // Get the analysis context for this file
        final context = collection.contextFor(filePath);

        // Analyze the file
        final result = await context.currentSession.getResolvedUnit(filePath);
        if (result is! ResolvedUnitResult) {
          warnings.add('Could not analyze file: ${file.path}');
          continue;
        }

        // Extract intents from this file
        final visitor = _IntentVisitor();
        result.unit.visitChildren(visitor);

        intents.addAll(visitor.intents);
      } on Object catch (e) {
        warnings.add('Failed to process file ${file.path}: $e');
      }
    }

    return intents;
  }

  /// Find the Dart SDK path
  ///
  /// Looks for the Dart SDK in Flutter cache or standalone Dart installation
  String? _findDartSdkPath() {
    try {
      // Try to find Flutter's Dart SDK
      final flutterPath = _findExecutable('flutter');
      if (flutterPath != null && flutterPath.isNotEmpty) {
        // Resolve symlinks to get the real path
        final realFlutterPath = File(flutterPath).resolveSymbolicLinksSync();
        // Flutter path is usually: /path/to/flutter/bin/flutter
        // Dart SDK is at: /path/to/flutter/bin/cache/dart-sdk
        final flutterBinDir = p.dirname(realFlutterPath);
        final flutterDir = p.dirname(flutterBinDir);
        final dartSdkPath = p.join(flutterDir, 'bin', 'cache', 'dart-sdk');
        if (Directory(dartSdkPath).existsSync()) {
          return dartSdkPath;
        }
      }
    } on Object catch (_) {
      // Ignore errors (e.g., if the executable is not found) and try next
      // method
    }

    try {
      // Try to find standalone Dart SDK
      final dartPath = _findExecutable('dart');
      if (dartPath != null && dartPath.isNotEmpty) {
        // Resolve symlinks to get the real path
        final realDartPath = File(dartPath).resolveSymbolicLinksSync();
        // Dart path is usually: /path/to/dart-sdk/bin/dart
        final dartBinDir = p.dirname(realDartPath);
        final dartSdkPath = p.dirname(dartBinDir);
        if (Directory(dartSdkPath).existsSync()) {
          return dartSdkPath;
        }
      }
    } on Object catch (_) {
      // Ignore errors and fallback to analyzer auto-detection
    }

    // Return null to let analyzer auto-detect (fallback)
    return null;
  }
}

/// Finds the full path of an executable by searching the system's PATH.
String? _findExecutable(String name) {
  try {
    final result = Platform.isWindows
        ? Process.runSync('where', [name])
        : Process.runSync('which', [name]);

    if (result.exitCode == 0) {
      // `where` on Windows can return multiple lines, take the first one.
      return (result.stdout as String).split('\n').first.trim();
    }
  } on Object {
    // Ignore exceptions, e.g., if `which` or `where` is not on PATH.
  }
  return null;
}

/// Common interface for classes that hold intent data.
abstract class _IntentDataContainer {
  String? identifier;
  String? title;
  String? description;
  String? category;
  bool? presentsResult;
  List<ExtractedParameter> parameters = [];
}

/// AST visitor that finds intent definitions
class _IntentVisitor extends RecursiveAstVisitor<void> {
  final List<ExtractedIntent> intents = [];

  // Track AppIntentBuilder instances and their configurations
  // Key: variable name, Value: builder configuration
  final Map<String, _BuilderConfig> _builderConfigs = {};

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // Pattern 2: final builder = AppIntentBuilder();
    final initializer = node.initializer;
    if (initializer is InstanceCreationExpression) {
      if (_isAppIntentBuilder(initializer)) {
        // node.name is a Token, get its lexeme for the string value
        final varName = node.name.toString();
        _builderConfigs[varName] = _BuilderConfig();
      }
    }

    // Pattern 1: Check if this is a chained builder ending in .build()
    if (initializer is MethodInvocation &&
        initializer.methodName.name == 'build') {
      final intent = _extractFromChainedBuilder(initializer);
      if (intent != null) {
        intents.add(intent);
      }
    }

    super.visitVariableDeclaration(node);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    // Handle standalone method invocations (Pattern 2)
    if (node.expression is MethodInvocation) {
      final methodCall = node.expression as MethodInvocation;
      final target = methodCall.target;

      // Track method calls on builder variables
      if (target is SimpleIdentifier) {
        final varName = target.name;
        if (_builderConfigs.containsKey(varName)) {
          final config = _builderConfigs[varName]!;
          _updateIntentData(methodCall, config);

          // Check if this is a .build() call
          if (methodCall.methodName.name == 'build') {
            final intent = config.toIntent();
            if (intent != null) {
              intents.add(intent);
            }
          }
        }
      }
    }

    super.visitExpressionStatement(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;

    // Pattern 2: Track method calls on builder variables
    if (target is SimpleIdentifier) {
      final varName = target.name;
      if (_builderConfigs.containsKey(varName)) {
        final config = _builderConfigs[varName]!;
        _updateIntentData(node, config);
      }
    }

    // Pattern 2: Check if this is a .build() call on a tracked builder
    if (node.methodName.name == 'build' && target is SimpleIdentifier) {
      final varName = target.name;
      if (_builderConfigs.containsKey(varName)) {
        final config = _builderConfigs[varName]!;
        final intent = config.toIntent();
        if (intent != null) {
          intents.add(intent);
        }
      }
    }

    super.visitMethodInvocation(node);
  }

  bool _isAppIntentBuilder(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.toString();
    return typeName.contains('AppIntentBuilder');
  }

  /// Extract intent from Pattern 1 (chained builder)
  ExtractedIntent? _extractFromChainedBuilder(MethodInvocation buildCall) {
    final intent = ExtractedIntent();

    var current = buildCall as AstNode?;
    while (current is MethodInvocation) {
      _updateIntentData(current, intent);
      current = current.target;
    }

    return intent.isValid ? intent : null;
  }

  /// Updates an intent data container from a method invocation.
  void _updateIntentData(MethodInvocation node, _IntentDataContainer data) {
    final method = node.methodName.name;
    final args = node.argumentList.arguments;

    if (args.isEmpty) return;

    // No default case is needed. We only care about the specific builder
    // methods for extracting intent data. Other methods (like .build()) are
    // intentionally ignored here.
    switch (method) {
      case 'identifier':
        data.identifier = _extractStringLiteral(args.first);
      case 'title':
        data.title = _extractStringLiteral(args.first);
      case 'description':
        data.description = _extractStringLiteral(args.first);
      case 'category':
        data.category = _extractEnumValue(
          args.first,
          expectedPrefix: 'IntentCategory',
        );
      case 'presentsResult':
        data.presentsResult = _extractBooleanLiteral(args.first);
      case 'parameter':
        final param = _extractParameter(args.first);
        if (param != null) {
          data.parameters.add(param);
        }
    }
  }

  String? _extractStringLiteral(Expression expr) {
    if (expr is StringLiteral) {
      return expr.stringValue;
    }
    return null;
  }

  String? _extractEnumValue(Expression expr, {String? expectedPrefix}) {
    // Handle: IntentCategory.fitness or AppIntentParameterType.string
    if (expr is PrefixedIdentifier) {
      final prefix = expr.prefix.name;

      // If expectedPrefix is provided, validate it matches
      if (expectedPrefix != null && prefix != expectedPrefix) {
        return null;
      }

      // Return the identifier part (e.g., 'fitness' from
      // 'IntentCategory.fitness' or 'string' from
      // 'AppIntentParameterType.string')
      return expr.identifier.name;
    }

    // Handle: imported enum constant (SimpleIdentifier)
    if (expr is SimpleIdentifier) {
      // Return the identifier name directly
      return expr.name;
    }

    return null;
  }

  bool? _extractBooleanLiteral(Expression expr) {
    if (expr is BooleanLiteral) {
      return expr.value;
    }
    return null;
  }

  /// Extracts parameter information from AppIntentParameter constructor
  ExtractedParameter? _extractParameter(Expression expr) {
    // Handle: const AppIntentParameter(name: 'x', title: 'X', ...)
    if (expr is! InstanceCreationExpression) return null;

    final typeName = expr.constructorName.type.toString();
    if (!typeName.contains('AppIntentParameter')) return null;

    final param = ExtractedParameter();

    // Extract named arguments
    for (final arg in expr.argumentList.arguments) {
      if (arg is NamedExpression) {
        final name = arg.name.label.name;
        final value = arg.expression;

        switch (name) {
          case 'name':
            param.name = _extractStringLiteral(value);
          case 'title':
            param.title = _extractStringLiteral(value);
          case 'type':
            param.type = _extractEnumValue(value);
          case 'isOptional':
            param.isOptional = _extractBooleanLiteral(value) ?? false;
          case 'defaultValue':
            param.defaultValue = _extractDefaultValue(value);
        }
      }
    }

    return param.isValid ? param : null;
  }

  /// Extracts default value from various expression types
  dynamic _extractDefaultValue(Expression expr) {
    if (expr is StringLiteral) return expr.stringValue;
    if (expr is IntegerLiteral) return expr.value;
    if (expr is DoubleLiteral) return expr.value;
    if (expr is BooleanLiteral) return expr.value;
    return null;
  }
}

/// Stores configuration for a builder variable (Pattern 2)
class _BuilderConfig extends _IntentDataContainer {
  ExtractedIntent? toIntent() {
    final intent = ExtractedIntent()
      ..identifier = identifier
      ..title = title
      ..description = description
      ..category = category
      ..presentsResult = presentsResult
      ..parameters = parameters;

    return intent.isValid ? intent : null;
  }
}

/// Represents an intent definition extracted from the source code.
class ExtractedIntent extends _IntentDataContainer {
  /// Whether the extracted intent has the minimum required fields.
  bool get isValid =>
      identifier != null && title != null && description != null;

  /// Gets the [IntentCategory] enum value from the raw [category] string.
  ///
  /// Defaults to [IntentCategory.general] if the category is null or unknown.
  IntentCategory get categoryEnum {
    if (category == null) return IntentCategory.general;

    // firstWhere with orElse never throws, so no try-catch needed
    return IntentCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => IntentCategory.general,
    );
  }

  @override
  String toString() => 'ExtractedIntent(identifier: $identifier, '
      'title: $title, category: $category, parameters: ${parameters.length})';
}

/// Represents a parameter extracted from AppIntentParameter
class ExtractedParameter {
  String? name;
  String? title;
  String? type;
  bool isOptional = false;
  dynamic defaultValue;

  /// Whether the extracted parameter has the minimum required fields
  bool get isValid => name != null && title != null && type != null;

  @override
  String toString() => 'ExtractedParameter(name: $name, type: $type, '
      'isOptional: $isOptional)';
}
