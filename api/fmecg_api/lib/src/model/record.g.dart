// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Record extends Record {
  @override
  final String fileUrl;
  @override
  final String filename;
  @override
  final int? fileSize;
  @override
  final int? id;
  @override
  final DateTime? insertedAt;
  @override
  final JsonObject? metadata;
  @override
  final DateTime? updatedAt;

  factory _$Record([void Function(RecordBuilder)? updates]) =>
      (RecordBuilder()..update(updates))._build();

  _$Record._(
      {required this.fileUrl,
      required this.filename,
      this.fileSize,
      this.id,
      this.insertedAt,
      this.metadata,
      this.updatedAt})
      : super._();
  @override
  Record rebuild(void Function(RecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecordBuilder toBuilder() => RecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Record &&
        fileUrl == other.fileUrl &&
        filename == other.filename &&
        fileSize == other.fileSize &&
        id == other.id &&
        insertedAt == other.insertedAt &&
        metadata == other.metadata &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fileUrl.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, fileSize.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, insertedAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Record')
          ..add('fileUrl', fileUrl)
          ..add('filename', filename)
          ..add('fileSize', fileSize)
          ..add('id', id)
          ..add('insertedAt', insertedAt)
          ..add('metadata', metadata)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RecordBuilder implements Builder<Record, RecordBuilder> {
  _$Record? _$v;

  String? _fileUrl;
  String? get fileUrl => _$this._fileUrl;
  set fileUrl(String? fileUrl) => _$this._fileUrl = fileUrl;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  int? _fileSize;
  int? get fileSize => _$this._fileSize;
  set fileSize(int? fileSize) => _$this._fileSize = fileSize;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  DateTime? _insertedAt;
  DateTime? get insertedAt => _$this._insertedAt;
  set insertedAt(DateTime? insertedAt) => _$this._insertedAt = insertedAt;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RecordBuilder() {
    Record._defaults(this);
  }

  RecordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fileUrl = $v.fileUrl;
      _filename = $v.filename;
      _fileSize = $v.fileSize;
      _id = $v.id;
      _insertedAt = $v.insertedAt;
      _metadata = $v.metadata;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Record other) {
    _$v = other as _$Record;
  }

  @override
  void update(void Function(RecordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Record build() => _build();

  _$Record _build() {
    final _$result = _$v ??
        _$Record._(
          fileUrl: BuiltValueNullFieldError.checkNotNull(
              fileUrl, r'Record', 'fileUrl'),
          filename: BuiltValueNullFieldError.checkNotNull(
              filename, r'Record', 'filename'),
          fileSize: fileSize,
          id: id,
          insertedAt: insertedAt,
          metadata: metadata,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
