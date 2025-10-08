import 'package:flutter_app_intents/src/models/result_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ResultLayout, () {
    group('text factory', () {
      test('creates text-only layout', () {
        final layout = ResultLayout.text(value: 'result');

        expect(layout.type, equals(ResultLayoutType.text));
        expect(layout.fields, hasLength(1));
      });

      test('creates field with correct properties', () {
        final layout = ResultLayout.text(value: 'temperature');

        final field = layout.fields.first;
        expect(field.key, equals('temperature'));
        expect(field.type, equals(ResultFieldType.text));
        expect(field.index, isNull);
      });

      test('accepts different value keys', () {
        final testCases = ['result', 'value', 'data', 'output'];

        for (final key in testCases) {
          final layout = ResultLayout.text(value: key);

          expect(layout.fields.first.key, equals(key));
        }
      });
    });

    group('card factory', () {
      test('creates card layout with title and description', () {
        final layout = ResultLayout.card(
          title: 'temp',
          description: 'conditions',
        );

        expect(layout.type, equals(ResultLayoutType.card));
        expect(layout.fields, hasLength(2));
      });

      test('creates fields with correct types', () {
        final layout = ResultLayout.card(
          title: 'title',
          description: 'desc',
        );

        final titleField = layout.fields[0];
        final descField = layout.fields[1];

        expect(titleField.type, equals(ResultFieldType.title));
        expect(descField.type, equals(ResultFieldType.description));
      });

      test('stores correct field keys', () {
        final layout = ResultLayout.card(
          title: 'temperature',
          description: 'forecast',
        );

        expect(layout.fields[0].key, equals('temperature'));
        expect(layout.fields[1].key, equals('forecast'));
      });

      test('includes image field when provided', () {
        final layout = ResultLayout.card(
          title: 'temp',
          description: 'conditions',
          image: 'weatherIcon',
        );

        expect(layout.fields, hasLength(3));

        final imageField = layout.fields[2];
        expect(imageField.key, equals('weatherIcon'));
        expect(imageField.type, equals(ResultFieldType.image));
      });

      test('does not include image field when null', () {
        final layout = ResultLayout.card(
          title: 'temp',
          description: 'conditions',
        );

        expect(layout.fields, hasLength(2));
        expect(
          layout.fields.where((f) => f.type == ResultFieldType.image),
          isEmpty,
        );
      });

      test('field order is title, description, image', () {
        final layout = ResultLayout.card(
          title: 'a',
          description: 'b',
          image: 'c',
        );

        expect(layout.fields[0].type, equals(ResultFieldType.title));
        expect(layout.fields[1].type, equals(ResultFieldType.description));
        expect(layout.fields[2].type, equals(ResultFieldType.image));
      });
    });

    group('list factory', () {
      test('creates list layout with items', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'item1'),
            const ListItem(title: 'item2'),
          ],
        );

        expect(layout.type, equals(ResultLayoutType.list));
        expect(layout.fields, isNotEmpty);
      });

      test('creates fields for each item', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'item1'),
            const ListItem(title: 'item2'),
            const ListItem(title: 'item3'),
          ],
        );

        // Each item creates at least one field (title)
        expect(layout.fields.length, greaterThanOrEqualTo(3));
      });

      test('creates title fields with correct properties', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'first'),
            const ListItem(title: 'second'),
          ],
        );

        final titleFields = layout.fields
            .where((f) => f.type == ResultFieldType.listItemTitle)
            .toList();

        expect(titleFields, hasLength(2));
        expect(titleFields[0].key, equals('first'));
        expect(titleFields[0].index, equals(0));
        expect(titleFields[1].key, equals('second'));
        expect(titleFields[1].index, equals(1));
      });

      test('creates subtitle fields when provided', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'item1', subtitle: 'sub1'),
            const ListItem(title: 'item2', subtitle: 'sub2'),
          ],
        );

        final subtitleFields = layout.fields
            .where((f) => f.type == ResultFieldType.listItemSubtitle)
            .toList();

        expect(subtitleFields, hasLength(2));
        expect(subtitleFields[0].key, equals('sub1'));
        expect(subtitleFields[0].index, equals(0));
        expect(subtitleFields[1].key, equals('sub2'));
        expect(subtitleFields[1].index, equals(1));
      });

      test('does not create subtitle fields when null', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'item1'),
            const ListItem(title: 'item2'),
          ],
        );

        final subtitleFields = layout.fields
            .where((f) => f.type == ResultFieldType.listItemSubtitle)
            .toList();

        expect(subtitleFields, isEmpty);
      });

      test('handles mixed items with and without subtitles', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'item1', subtitle: 'sub1'),
            const ListItem(title: 'item2'),
            const ListItem(title: 'item3', subtitle: 'sub3'),
          ],
        );

        final titleFields = layout.fields
            .where((f) => f.type == ResultFieldType.listItemTitle)
            .toList();
        final subtitleFields = layout.fields
            .where((f) => f.type == ResultFieldType.listItemSubtitle)
            .toList();

        expect(titleFields, hasLength(3));
        expect(subtitleFields, hasLength(2));
        expect(subtitleFields[0].index, equals(0));
        expect(subtitleFields[1].index, equals(2));
      });

      test('handles empty list', () {
        final layout = ResultLayout.list(items: []);

        expect(layout.type, equals(ResultLayoutType.list));
        expect(layout.fields, isEmpty);
      });

      test('maintains correct field order', () {
        final layout = ResultLayout.list(
          items: [
            const ListItem(title: 'a', subtitle: 'subA'),
            const ListItem(title: 'b', subtitle: 'subB'),
          ],
        );

        // Should be: title0, subtitle0, title1, subtitle1
        expect(layout.fields[0].type, equals(ResultFieldType.listItemTitle));
        expect(layout.fields[0].index, equals(0));

        expect(layout.fields[1].type, equals(ResultFieldType.listItemSubtitle));
        expect(layout.fields[1].index, equals(0));

        expect(layout.fields[2].type, equals(ResultFieldType.listItemTitle));
        expect(layout.fields[2].index, equals(1));

        expect(layout.fields[3].type, equals(ResultFieldType.listItemSubtitle));
        expect(layout.fields[3].index, equals(1));
      });
    });

    group('properties', () {
      test('ResultLayout has correct properties', () {
        final layout = ResultLayout.text(value: 'test');

        expect(layout, isA<ResultLayout>());
        expect(layout.type, isA<ResultLayoutType>());
        expect(layout.fields, isA<List<ResultField>>());
      });

      test('fields list is populated correctly', () {
        final layout = ResultLayout.text(value: 'test');

        expect(layout.fields, isNotEmpty);
        expect(layout.fields.first, isA<ResultField>());
      });

      test('each layout type has distinct structure', () {
        final textLayout = ResultLayout.text(value: 'v');
        final cardLayout = ResultLayout.card(title: 't', description: 'd');
        final listLayout = ResultLayout.list(
          items: [
            const ListItem(title: 'item'),
          ],
        );

        expect(textLayout.type, equals(ResultLayoutType.text));
        expect(cardLayout.type, equals(ResultLayoutType.card));
        expect(listLayout.type, equals(ResultLayoutType.list));
      });
    });
  });

  group('ResultLayoutType', () {
    test('has text type', () {
      expect(ResultLayoutType.text, isA<ResultLayoutType>());
    });

    test('has card type', () {
      expect(ResultLayoutType.card, isA<ResultLayoutType>());
    });

    test('has list type', () {
      expect(ResultLayoutType.list, isA<ResultLayoutType>());
    });

    test('has exactly three values', () {
      expect(ResultLayoutType.values, hasLength(3));
    });

    test('enum values have correct names', () {
      expect(ResultLayoutType.text.name, equals('text'));
      expect(ResultLayoutType.card.name, equals('card'));
      expect(ResultLayoutType.list.name, equals('list'));
    });
  });

  group('ResultField', () {
    test('can be created with required parameters', () {
      const field = ResultField(
        key: 'temperature',
        type: ResultFieldType.text,
      );

      expect(field.key, equals('temperature'));
      expect(field.type, equals(ResultFieldType.text));
      expect(field.index, isNull);
    });

    test('can be created with index', () {
      const field = ResultField(
        key: 'item',
        type: ResultFieldType.listItemTitle,
        index: 5,
      );

      expect(field.key, equals('item'));
      expect(field.type, equals(ResultFieldType.listItemTitle));
      expect(field.index, equals(5));
    });

    test('is const constructible', () {
      const field = ResultField(
        key: 'test',
        type: ResultFieldType.text,
      );

      expect(field, isA<ResultField>());
    });

    test('supports all field types', () {
      for (final fieldType in ResultFieldType.values) {
        final field = ResultField(
          key: 'test',
          type: fieldType,
        );

        expect(field.type, equals(fieldType));
      }
    });

    test('allows null index for non-list fields', () {
      const field = ResultField(
        key: 'title',
        type: ResultFieldType.title,
      );

      expect(field.index, isNull);
    });

    test('allows zero index', () {
      const field = ResultField(
        key: 'first',
        type: ResultFieldType.listItemTitle,
        index: 0,
      );

      expect(field.index, equals(0));
    });
  });

  group('ResultFieldType', () {
    test('has text type', () {
      expect(ResultFieldType.text, isA<ResultFieldType>());
    });

    test('has title type', () {
      expect(ResultFieldType.title, isA<ResultFieldType>());
    });

    test('has description type', () {
      expect(ResultFieldType.description, isA<ResultFieldType>());
    });

    test('has image type', () {
      expect(ResultFieldType.image, isA<ResultFieldType>());
    });

    test('has listItemTitle type', () {
      expect(ResultFieldType.listItemTitle, isA<ResultFieldType>());
    });

    test('has listItemSubtitle type', () {
      expect(ResultFieldType.listItemSubtitle, isA<ResultFieldType>());
    });

    test('has exactly six values', () {
      expect(ResultFieldType.values, hasLength(6));
    });

    test('enum values have correct names', () {
      expect(ResultFieldType.text.name, equals('text'));
      expect(ResultFieldType.title.name, equals('title'));
      expect(ResultFieldType.description.name, equals('description'));
      expect(ResultFieldType.image.name, equals('image'));
      expect(ResultFieldType.listItemTitle.name, equals('listItemTitle'));
      expect(
        ResultFieldType.listItemSubtitle.name,
        equals('listItemSubtitle'),
      );
    });
  });

  group('ListItem', () {
    test('can be created with title only', () {
      const item = ListItem(title: 'My Title');

      expect(item.title, equals('My Title'));
      expect(item.subtitle, isNull);
    });

    test('can be created with title and subtitle', () {
      const item = ListItem(
        title: 'My Title',
        subtitle: 'My Subtitle',
      );

      expect(item.title, equals('My Title'));
      expect(item.subtitle, equals('My Subtitle'));
    });

    test('is const constructible', () {
      const item = ListItem(title: 'test');

      expect(item, isA<ListItem>());
    });

    test('supports empty strings', () {
      const item = ListItem(
        title: '',
        subtitle: '',
      );

      expect(item.title, equals(''));
      expect(item.subtitle, equals(''));
    });

    test('supports long strings', () {
      const longTitle = 'This is a very long title that might be used in a '
          'real application with lots of text';
      const longSubtitle = 'This is a very long subtitle that provides '
          'additional details';

      const item = ListItem(
        title: longTitle,
        subtitle: longSubtitle,
      );

      expect(item.title, equals(longTitle));
      expect(item.subtitle, equals(longSubtitle));
    });

    test('supports special characters', () {
      const item = ListItem(
        title: 'Title with émojis 🎉 and spëcial chars',
        subtitle: r'Subtitle with <tags> & symbols @#$%',
      );

      expect(item.title, contains('🎉'));
      expect(item.subtitle, contains('<tags>'));
    });
  });

  group('integration scenarios', () {
    test('weather result layout example', () {
      final layout = ResultLayout.card(
        title: 'temperature',
        description: 'conditions',
        image: 'weatherIcon',
      );

      expect(layout.type, equals(ResultLayoutType.card));
      expect(layout.fields, hasLength(3));

      // Verify structure matches expected usage
      final fieldsByType = <ResultFieldType, ResultField>{};
      for (final field in layout.fields) {
        fieldsByType[field.type] = field;
      }

      expect(fieldsByType[ResultFieldType.title]?.key, equals('temperature'));
      expect(
        fieldsByType[ResultFieldType.description]?.key,
        equals('conditions'),
      );
      expect(fieldsByType[ResultFieldType.image]?.key, equals('weatherIcon'));
    });

    test('search results list layout example', () {
      final layout = ResultLayout.list(
        items: [
          const ListItem(
            title: 'Result 1',
            subtitle: 'Description 1',
          ),
          const ListItem(
            title: 'Result 2',
            subtitle: 'Description 2',
          ),
          const ListItem(
            title: 'Result 3',
          ),
        ],
      );

      expect(layout.type, equals(ResultLayoutType.list));

      final titles = layout.fields
          .where((f) => f.type == ResultFieldType.listItemTitle)
          .toList();
      final subtitles = layout.fields
          .where((f) => f.type == ResultFieldType.listItemSubtitle)
          .toList();

      expect(titles, hasLength(3));
      expect(subtitles, hasLength(2));
    });

    test('simple text result example', () {
      final layout = ResultLayout.text(value: 'balance');

      expect(layout.type, equals(ResultLayoutType.text));
      expect(layout.fields.first.key, equals('balance'));
    });

    test('multiple layouts can coexist', () {
      final layouts = [
        ResultLayout.text(value: 'value1'),
        ResultLayout.card(
          title: 'title1',
          description: 'desc1',
        ),
        ResultLayout.list(
          items: [const ListItem(title: 'item1')],
        ),
      ];

      expect(layouts[0].type, equals(ResultLayoutType.text));
      expect(layouts[1].type, equals(ResultLayoutType.card));
      expect(layouts[2].type, equals(ResultLayoutType.list));
    });
  });

  group('edge cases', () {
    test('card with very long keys', () {
      const longKey = 'this_is_a_very_long_key_name_that_might_be_used_'
          'in_some_scenarios_with_complex_data_structures';

      final layout = ResultLayout.card(
        title: longKey,
        description: longKey,
        image: longKey,
      );

      expect(layout.fields[0].key, equals(longKey));
      expect(layout.fields[1].key, equals(longKey));
      expect(layout.fields[2].key, equals(longKey));
    });

    test('list with many items', () {
      final items = List.generate(
        100,
        (i) => ListItem(title: 'item$i', subtitle: 'sub$i'),
      );

      final layout = ResultLayout.list(items: items);

      expect(layout.fields.length, equals(200)); // 100 titles + 100 subtitles
    });

    test('list with single item', () {
      final layout = ResultLayout.list(
        items: [const ListItem(title: 'only')],
      );

      expect(layout.fields, hasLength(1));
      expect(layout.fields.first.index, equals(0));
    });

    test('all field types are representable', () {
      // Text layout
      final textLayout = ResultLayout.text(value: 'v');
      expect(textLayout.fields.first.type, equals(ResultFieldType.text));

      // Card layout with all field types
      final cardLayout = ResultLayout.card(
        title: 't',
        description: 'd',
        image: 'i',
      );

      final types = cardLayout.fields.map((f) => f.type).toSet();
      expect(types, contains(ResultFieldType.title));
      expect(types, contains(ResultFieldType.description));
      expect(types, contains(ResultFieldType.image));

      // List layout with subtitle types
      final listLayout = ResultLayout.list(
        items: [const ListItem(title: 't', subtitle: 's')],
      );

      final listTypes = listLayout.fields.map((f) => f.type).toSet();
      expect(listTypes, contains(ResultFieldType.listItemTitle));
      expect(listTypes, contains(ResultFieldType.listItemSubtitle));

      // All 6 field types should be covered
      final allTypes = {
        ...types,
        ...listTypes,
        textLayout.fields.first.type,
      };
      expect(allTypes, hasLength(6));
    });
  });
}
