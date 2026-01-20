// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecordResponse extends RecordResponse {
  @override
  final Record? data;

  factory _$RecordResponse([void Function(RecordResponseBuilder)? updates]) =>
      (RecordResponseBuilder()..update(updates))._build();

  _$RecordResponse._({this.data}) : super._();
  @override
  RecordResponse rebuild(void Function(RecordResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecordResponseBuilder toBuilder() => RecordResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecordResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecordResponse')..add('data', data))
        .toString();
  }
}

class RecordResponseBuilder
    implements Builder<RecordResponse, RecordResponseBuilder> {
  _$RecordResponse? _$v;

  RecordBuilder? _data;
  RecordBuilder get data => _$this._data ??= RecordBuilder();
  set data(RecordBuilder? data) => _$this._data = data;

  RecordResponseBuilder() {
    RecordResponse._defaults(this);
  }

  RecordResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecordResponse other) {
    _$v = other as _$RecordResponse;
  }

  @override
  void update(void Function(RecordResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecordResponse build() => _build();

  _$RecordResponse _build() {
    _$RecordResponse _$result;
    try {
      _$result = _$v ??
          _$RecordResponse._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecordResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
