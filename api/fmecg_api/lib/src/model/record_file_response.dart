//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'record_file_response.g.dart';

/// JSON file content response
///
/// Properties:
/// * [data] - File content as JSON
@BuiltValue()
abstract class RecordFileResponse
    implements Built<RecordFileResponse, RecordFileResponseBuilder> {
  /// File content as JSON
  @BuiltValueField(wireName: r'data')
  JsonObject? get data;

  RecordFileResponse._();

  factory RecordFileResponse([void updates(RecordFileResponseBuilder b)]) =
      _$RecordFileResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecordFileResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecordFileResponse> get serializer =>
      _$RecordFileResponseSerializer();
}

class _$RecordFileResponseSerializer
    implements PrimitiveSerializer<RecordFileResponse> {
  @override
  final Iterable<Type> types = const [RecordFileResponse, _$RecordFileResponse];

  @override
  final String wireName = r'RecordFileResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecordFileResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RecordFileResponse object, {
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
    required RecordFileResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.data = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecordFileResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecordFileResponseBuilder();
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
