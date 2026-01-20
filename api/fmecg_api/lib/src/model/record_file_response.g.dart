// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_file_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecordFileResponse extends RecordFileResponse {
  @override
  final JsonObject? data;

  factory _$RecordFileResponse(
          [void Function(RecordFileResponseBuilder)? updates]) =>
      (RecordFileResponseBuilder()..update(updates))._build();

  _$RecordFileResponse._({this.data}) : super._();
  @override
  RecordFileResponse rebuild(
          void Function(RecordFileResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecordFileResponseBuilder toBuilder() =>
      RecordFileResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecordFileResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RecordFileResponse')
          ..add('data', data))
        .toString();
  }
}

class RecordFileResponseBuilder
    implements Builder<RecordFileResponse, RecordFileResponseBuilder> {
  _$RecordFileResponse? _$v;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  RecordFileResponseBuilder() {
    RecordFileResponse._defaults(this);
  }

  RecordFileResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecordFileResponse other) {
    _$v = other as _$RecordFileResponse;
  }

  @override
  void update(void Function(RecordFileResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecordFileResponse build() => _build();

  _$RecordFileResponse _build() {
    final _$result = _$v ??
        _$RecordFileResponse._(
          data: data,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
