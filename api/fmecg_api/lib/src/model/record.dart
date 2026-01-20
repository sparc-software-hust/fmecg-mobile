//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'record.g.dart';

/// A record with file data
///
/// Properties:
/// * [fileUrl] - URL to access the file
/// * [filename] - Original filename
/// * [fileSize] - File size in bytes
/// * [id] - Record ID
/// * [insertedAt] - Creation timestamp
/// * [metadata] - Additional metadata
/// * [updatedAt] - Update timestamp
@BuiltValue()
abstract class Record implements Built<Record, RecordBuilder> {
  /// URL to access the file
  @BuiltValueField(wireName: r'file_url')
  String get fileUrl;

  /// Original filename
  @BuiltValueField(wireName: r'filename')
  String get filename;

  /// File size in bytes
  @BuiltValueField(wireName: r'file_size')
  int? get fileSize;

  /// Record ID
  @BuiltValueField(wireName: r'id')
  int? get id;

  /// Creation timestamp
  @BuiltValueField(wireName: r'inserted_at')
  DateTime? get insertedAt;

  /// Additional metadata
  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  /// Update timestamp
  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  Record._();

  factory Record([void updates(RecordBuilder b)]) = _$Record;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecordBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Record> get serializer => _$RecordSerializer();
}

class _$RecordSerializer implements PrimitiveSerializer<Record> {
  @override
  final Iterable<Type> types = const [Record, _$Record];

  @override
  final String wireName = r'Record';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Record object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'file_url';
    yield serializers.serialize(
      object.fileUrl,
      specifiedType: const FullType(String),
    );
    yield r'filename';
    yield serializers.serialize(
      object.filename,
      specifiedType: const FullType(String),
    );
    if (object.fileSize != null) {
      yield r'file_size';
      yield serializers.serialize(
        object.fileSize,
        specifiedType: const FullType(int),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.insertedAt != null) {
      yield r'inserted_at';
      yield serializers.serialize(
        object.insertedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Record object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecordBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'file_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fileUrl = valueDes;
          break;
        case r'filename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.filename = valueDes;
          break;
        case r'file_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.fileSize = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'inserted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.insertedAt = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.metadata = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Record deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecordBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
