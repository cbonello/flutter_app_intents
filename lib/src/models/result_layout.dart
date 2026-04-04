import 'package:equatable/equatable.dart';

/// Defines how an intent result should be displayed.
///
/// For iOS, this controls the IntentDialog presentation.
/// For Android, this generates a widget layout using RemoteViews.
class ResultLayout extends Equatable {
  const ResultLayout._({
    required this.type,
    required this.fields,
  });

  /// Creates a simple text-only result layout.
  ///
  /// Example:
  /// ```dart
  /// ResultLayout.text(
  ///   value: 'result',
  /// )
  /// ```
  factory ResultLayout.text({
    required String value,
  }) {
    return ResultLayout._(
      type: ResultLayoutType.text,
      fields: [
        ResultField(
          key: value,
          type: ResultFieldType.text,
        ),
      ],
    );
  }

  /// Creates a card layout with title, description, and optional image.
  ///
  /// Example:
  /// ```dart
  /// ResultLayout.card(
  ///   title: 'title',
  ///   description: 'description',
  ///   image: 'iconName',
  /// )
  /// ```
  factory ResultLayout.card({
    required String title,
    required String description,
    String? image,
  }) {
    final fields = <ResultField>[
      ResultField(
        key: title,
        type: ResultFieldType.title,
      ),
      ResultField(
        key: description,
        type: ResultFieldType.description,
      ),
    ];

    if (image != null) {
      fields.add(
        ResultField(
          key: image,
          type: ResultFieldType.image,
        ),
      );
    }

    return ResultLayout._(
      type: ResultLayoutType.card,
      fields: fields,
    );
  }

  /// Creates a list layout with multiple items.
  ///
  /// Each item is displayed as a title + optional subtitle.
  ///
  /// Example:
  /// ```dart
  /// ResultLayout.list(
  ///   items: [
  ///     ListItem(title: 'item1Title', subtitle: 'item1Subtitle'),
  ///     ListItem(title: 'item2Title'),
  ///   ],
  /// )
  /// ```
  factory ResultLayout.list({
    required List<ListItem> items,
  }) {
    final fields = <ResultField>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      fields.add(
        ResultField(
          key: item.title,
          type: ResultFieldType.listItemTitle,
          index: i,
        ),
      );
      if (item.subtitle != null) {
        fields.add(
          ResultField(
            key: item.subtitle!,
            type: ResultFieldType.listItemSubtitle,
            index: i,
          ),
        );
      }
    }

    return ResultLayout._(
      type: ResultLayoutType.list,
      fields: fields,
    );
  }

  /// The type of layout to use.
  final ResultLayoutType type;

  /// The fields to display in the result.
  final List<ResultField> fields;

  @override
  List<Object?> get props => [type, fields];
}

/// The type of result layout.
enum ResultLayoutType {
  /// Simple text-only layout.
  text,

  /// Card layout with title, description, and optional image.
  card,

  /// List layout with multiple items.
  list,
}

/// A field in a result layout.
class ResultField extends Equatable {
  const ResultField({
    required this.key,
    required this.type,
    this.index,
  });

  /// The key that maps to the result data.
  final String key;

  /// The type of field.
  final ResultFieldType type;

  /// The index of the item (for list items).
  final int? index;

  @override
  List<Object?> get props => [key, type, index];
}

/// The type of result field.
enum ResultFieldType {
  /// Plain text.
  text,

  /// Title text (larger, bold).
  title,

  /// Description text (smaller, regular).
  description,

  /// Image reference.
  image,

  /// List item title.
  listItemTitle,

  /// List item subtitle.
  listItemSubtitle,
}

/// A list item with title and optional subtitle.
class ListItem extends Equatable {
  const ListItem({
    required this.title,
    this.subtitle,
  });

  /// The title of the list item.
  final String title;

  /// The optional subtitle of the list item.
  final String? subtitle;

  @override
  List<Object?> get props => [title, subtitle];
}
