import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppIntentParameter, () {
    group('constructor', () {
      test('creates parameter with required fields', () {
        const parameter = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
        );

        expect(parameter.name, equals('test_param'));
        expect(parameter.title, equals('Test Parameter'));
        expect(parameter.type, equals(AppIntentParameterType.string));
        expect(parameter.description, isNull);
        expect(parameter.isOptional, isFalse);
        expect(parameter.defaultValue, isNull);
      });

      test('creates parameter with all optional fields', () {
        const parameter = AppIntentParameter(
          name: 'complex_param',
          title: 'Complex Parameter',
          type: AppIntentParameterType.integer,
          description: 'A complex parameter for testing',
          isOptional: true,
          defaultValue: 42,
        );

        expect(parameter.name, equals('complex_param'));
        expect(parameter.title, equals('Complex Parameter'));
        expect(parameter.type, equals(AppIntentParameterType.integer));
        expect(
          parameter.description,
          equals('A complex parameter for testing'),
        );
        expect(parameter.isOptional, isTrue);
        expect(parameter.defaultValue, equals(42));
      });

      test('creates parameter with different types', () {
        const stringParam = AppIntentParameter(
          name: 'string_param',
          title: 'String Parameter',
          type: AppIntentParameterType.string,
        );

        const boolParam = AppIntentParameter(
          name: 'bool_param',
          title: 'Boolean Parameter',
          type: AppIntentParameterType.boolean,
        );

        const doubleParam = AppIntentParameter(
          name: 'double_param',
          title: 'Double Parameter',
          type: AppIntentParameterType.double,
        );

        expect(stringParam.type, equals(AppIntentParameterType.string));
        expect(boolParam.type, equals(AppIntentParameterType.boolean));
        expect(doubleParam.type, equals(AppIntentParameterType.double));
      });
    });

    group(AppIntentParameter.fromMap, () {
      test('creates parameter from valid map', () {
        final map = <String, dynamic>{
          'name': 'from_map_param',
          'title': 'From Map Parameter',
          'type': 'integer',
          'description': 'Created from map',
          'isOptional': true,
          'defaultValue': 123,
        };

        final parameter = AppIntentParameter.fromMap(map);

        expect(parameter.name, equals('from_map_param'));
        expect(parameter.title, equals('From Map Parameter'));
        expect(parameter.type, equals(AppIntentParameterType.integer));
        expect(parameter.description, equals('Created from map'));
        expect(parameter.isOptional, isTrue);
        expect(parameter.defaultValue, equals(123));
      });

      test('creates parameter with defaults when optional fields missing', () {
        final map = <String, dynamic>{
          'name': 'minimal_param',
          'title': 'Minimal Parameter',
          'type': 'string',
        };

        final parameter = AppIntentParameter.fromMap(map);

        expect(parameter.name, equals('minimal_param'));
        expect(parameter.title, equals('Minimal Parameter'));
        expect(parameter.type, equals(AppIntentParameterType.string));
        expect(parameter.description, isNull);
        expect(parameter.isOptional, isFalse);
        expect(parameter.defaultValue, isNull);
      });

      test('handles unknown parameter type', () {
        final map = <String, dynamic>{
          'name': 'test_param',
          'title': 'Test Parameter',
          'type': 'unknown_type',
        };

        final parameter = AppIntentParameter.fromMap(map);

        expect(parameter.type, equals(AppIntentParameterType.string));
      });

      test('creates parameter for each type', () {
        final typeTests = [
          ('string', AppIntentParameterType.string),
          ('integer', AppIntentParameterType.integer),
          ('boolean', AppIntentParameterType.boolean),
          ('double', AppIntentParameterType.double),
          ('date', AppIntentParameterType.date),
          ('url', AppIntentParameterType.url),
          ('file', AppIntentParameterType.file),
          ('entity', AppIntentParameterType.entity),
        ];

        for (final (typeString, expectedType) in typeTests) {
          final map = <String, dynamic>{
            'name': 'test_param',
            'title': 'Test Parameter',
            'type': typeString,
          };

          final parameter = AppIntentParameter.fromMap(map);

          expect(
            parameter.type,
            equals(expectedType),
            reason: 'Failed for type $typeString',
          );
        }
      });
    });

    group('toMap()', () {
      test('converts parameter to map correctly', () {
        const parameter = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.boolean,
          description: 'A test parameter',
          isOptional: true,
          defaultValue: true,
        );

        final map = parameter.toMap();

        expect(
          map,
          equals({
            'name': 'test_param',
            'title': 'Test Parameter',
            'type': 'boolean',
            'description': 'A test parameter',
            'isOptional': true,
            'defaultValue': true,
          }),
        );
      });

      test('converts parameter with null optional fields', () {
        const parameter = AppIntentParameter(
          name: 'simple_param',
          title: 'Simple Parameter',
          type: AppIntentParameterType.string,
        );

        final map = parameter.toMap();

        expect(
          map,
          equals({
            'name': 'simple_param',
            'title': 'Simple Parameter',
            'type': 'string',
            'description': null,
            'isOptional': false,
            'defaultValue': null,
          }),
        );
      });

      test('converts all parameter types correctly', () {
        final typeTests = [
          (AppIntentParameterType.string, 'string'),
          (AppIntentParameterType.integer, 'integer'),
          (AppIntentParameterType.boolean, 'boolean'),
          (AppIntentParameterType.double, 'double'),
          (AppIntentParameterType.date, 'date'),
          (AppIntentParameterType.url, 'url'),
          (AppIntentParameterType.file, 'file'),
          (AppIntentParameterType.entity, 'entity'),
        ];

        for (final (paramType, expectedString) in typeTests) {
          final parameter = AppIntentParameter(
            name: 'test_param',
            title: 'Test Parameter',
            type: paramType,
          );

          final map = parameter.toMap();

          expect(
            map['type'],
            equals(expectedString),
            reason: 'Failed for type $paramType',
          );
        }
      });
    });

    group('equality', () {
      test('two parameters with same properties are equal', () {
        const param1 = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
          description: 'Test description',
          isOptional: true,
          defaultValue: 'default',
        );

        const param2 = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
          description: 'Test description',
          isOptional: true,
          defaultValue: 'default',
        );

        expect(param1, equals(param2));
        expect(param1.hashCode, equals(param2.hashCode));
      });

      test('two parameters with different properties are not equal', () {
        const param1 = AppIntentParameter(
          name: 'param1',
          title: 'Parameter 1',
          type: AppIntentParameterType.string,
        );

        const param2 = AppIntentParameter(
          name: 'param2',
          title: 'Parameter 2',
          type: AppIntentParameterType.string,
        );

        expect(param1, isNot(equals(param2)));
      });

      test('parameters with different types are not equal', () {
        const param1 = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
        );

        const param2 = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.integer,
        );

        expect(param1, isNot(equals(param2)));
      });
    });

    group('round-trip conversion', () {
      test('toMap and fromMap preserve all data', () {
        const original = AppIntentParameter(
          name: 'roundtrip_param',
          title: 'Roundtrip Parameter',
          type: AppIntentParameterType.double,
          description: 'Testing roundtrip conversion',
          isOptional: true,
          defaultValue: 3.14159,
        );

        final map = original.toMap();
        final reconstructed = AppIntentParameter.fromMap(map);

        expect(reconstructed, equals(original));
      });

      test('round-trip with minimal data', () {
        const original = AppIntentParameter(
          name: 'minimal_param',
          title: 'Minimal Parameter',
          type: AppIntentParameterType.entity,
        );

        final map = original.toMap();
        final reconstructed = AppIntentParameter.fromMap(map);

        expect(reconstructed, equals(original));
      });

      test('round-trip with complex default values', () {
        const original = AppIntentParameter(
          name: 'complex_param',
          title: 'Complex Parameter',
          type: AppIntentParameterType.string,
          defaultValue: 'complex default value with spaces and symbols!@#',
        );

        final map = original.toMap();
        final reconstructed = AppIntentParameter.fromMap(map);

        expect(reconstructed, equals(original));
      });
    });
  });

  group(AppIntentParameterType, () {
    test('has all expected values', () {
      expect(AppIntentParameterType.values, hasLength(8));
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.string),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.integer),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.boolean),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.double),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.date),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.url),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.file),
      );
      expect(
        AppIntentParameterType.values,
        contains(AppIntentParameterType.entity),
      );
    });

    test('enum names are correct', () {
      expect(AppIntentParameterType.string.name, equals('string'));
      expect(AppIntentParameterType.integer.name, equals('integer'));
      expect(AppIntentParameterType.boolean.name, equals('boolean'));
      expect(AppIntentParameterType.double.name, equals('double'));
      expect(AppIntentParameterType.date.name, equals('date'));
      expect(AppIntentParameterType.url.name, equals('url'));
      expect(AppIntentParameterType.file.name, equals('file'));
      expect(AppIntentParameterType.entity.name, equals('entity'));
    });
  });
}
