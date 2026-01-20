//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:fmecg_api/src/model/record.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'record_response.g.dart';

/// Response schema for single record
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class RecordResponse
    implements Built<RecordResponse, RecordResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Record? get data;

  RecordResponse._();

  factory RecordResponse([void updates(RecordResponseBuilder b)]) =
      _$RecordResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecordResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecordResponse> get serializer =>
      _$RecordResponseSerializer();
}

class _$RecordResponseSerializer
    implements PrimitiveSerializer<RecordResponse> {
  @override
  final Iterable<Type> types = const [RecordResponse, _$RecordResponse];

  @override
  final String wireName = r'RecordResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecordResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(Record),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RecordResponse object, {
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
    required RecordResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Record),
          ) as Record;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecordResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecordResponseBuilder();
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
