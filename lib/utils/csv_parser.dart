import 'dart:io';

/// CSV parser for reading and writing ECG data files.
/// 
/// Handles parsing of CSV files with time and channel data columns.
class CsvParser {
  /// Default headers for 6-channel ECG data.
  static const List<String> defaultEcgHeaders = [
    'time',
    'ch1',
    'ch2',
    'ch3',
    'ch4',
    'ch5',
    'ch6',
  ];

  /// Parse a CSV file and return the data as a list of rows.
  /// 
  /// [file] - The CSV file to parse
  /// [skipHeader] - Whether to skip the first row (header)
  /// 
  /// Returns a list of rows, where each row is a list of string values.
  static Future<List<List<String>>> parseFile(File file, {bool skipHeader = true}) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }

    final String content = await file.readAsString();
    return parseString(content, skipHeader: skipHeader);
  }

  /// Parse a CSV string and return the data as a list of rows.
  /// 
  /// [content] - The CSV content as a string
  /// [skipHeader] - Whether to skip the first row (header)
  static List<List<String>> parseString(String content, {bool skipHeader = true}) {
    final List<String> lines = content.trim().split('\n');
    
    if (lines.isEmpty) {
      return [];
    }

    final int startIndex = skipHeader ? 1 : 0;
    final List<List<String>> rows = [];

    for (int i = startIndex; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isNotEmpty) {
        rows.add(line.split(','));
      }
    }

    return rows;
  }

  /// Parse a CSV file and return the data as typed ECG data.
  /// 
  /// [file] - The CSV file to parse
  /// 
  /// Returns a list of EcgDataRow objects.
  static Future<List<EcgDataRow>> parseEcgFile(File file) async {
    final List<List<String>> rows = await parseFile(file, skipHeader: true);
    return rows.map((row) => EcgDataRow.fromCsvRow(row)).toList();
  }

  /// Convert a list of values to a CSV row string.
  /// 
  /// [values] - List of values to convert
  /// [decimalPlaces] - Number of decimal places for double values
  static String rowToString(List<dynamic> values, {int decimalPlaces = 6}) {
    return values.map((value) {
      if (value is double) {
        return value.toStringAsFixed(decimalPlaces);
      }
      return value.toString();
    }).join(',');
  }

  /// Convert a list of rows to a complete CSV string with headers.
  /// 
  /// [rows] - List of rows to convert
  /// [headers] - Optional custom headers (uses defaultEcgHeaders if not provided)
  /// [decimalPlaces] - Number of decimal places for double values
  static String toCSVString(
    List<List<dynamic>> rows, {
    List<String>? headers,
    int decimalPlaces = 6,
  }) {
    final StringBuffer sb = StringBuffer();
    
    // Write headers
    final List<String> headerRow = headers ?? defaultEcgHeaders;
    sb.writeln(headerRow.join(','));
    
    // Write data rows
    for (final row in rows) {
      sb.writeln(rowToString(row, decimalPlaces: decimalPlaces));
    }
    
    return sb.toString();
  }

  /// Write data to a CSV file.
  /// 
  /// [file] - The file to write to
  /// [rows] - List of rows to write
  /// [headers] - Optional custom headers
  /// [append] - Whether to append to existing file or overwrite
  static Future<void> writeToFile(
    File file,
    List<List<dynamic>> rows, {
    List<String>? headers,
    bool append = false,
  }) async {
    final String content = toCSVString(rows, headers: headers);
    
    if (append) {
      await file.writeAsString(content, mode: FileMode.append);
    } else {
      await file.writeAsString(content);
    }
  }

  /// Get the headers from a CSV file.
  /// 
  /// [file] - The CSV file to read headers from
  static Future<List<String>> getHeaders(File file) async {
    if (!await file.exists()) {
      return [];
    }

    final String content = await file.readAsString();
    final List<String> lines = content.trim().split('\n');
    
    if (lines.isEmpty) {
      return [];
    }

    return lines.first.split(',');
  }

  /// Count the number of data rows in a CSV file (excluding header).
  /// 
  /// [file] - The CSV file to count rows in
  static Future<int> countRows(File file) async {
    if (!await file.exists()) {
      return 0;
    }

    final String content = await file.readAsString();
    final List<String> lines = content.trim().split('\n');
    
    // Subtract 1 for header
    return lines.length > 1 ? lines.length - 1 : 0;
  }
}

/// Represents a single row of ECG data with time and 6 channel values.
class EcgDataRow {
  final double time;
  final List<double> channelValues;

  EcgDataRow({
    required this.time,
    required this.channelValues,
  });

  /// Create an EcgDataRow from a CSV row (list of strings).
  factory EcgDataRow.fromCsvRow(List<String> row) {
    if (row.isEmpty) {
      throw FormatException('Empty row');
    }

    final double time = double.tryParse(row[0]) ?? 0.0;
    final List<double> channels = [];

    for (int i = 1; i < row.length && i <= 6; i++) {
      channels.add(double.tryParse(row[i]) ?? 0.0);
    }

    // Pad with zeros if less than 6 channels
    while (channels.length < 6) {
      channels.add(0.0);
    }

    return EcgDataRow(time: time, channelValues: channels);
  }

  /// Get a specific channel value (0-indexed).
  double getChannel(int index) {
    if (index < 0 || index >= channelValues.length) {
      return 0.0;
    }
    return channelValues[index];
  }

  /// Convert to a list for CSV output.
  List<double> toList() {
    return [time, ...channelValues];
  }

  @override
  String toString() {
    return 'EcgDataRow(time: $time, channels: $channelValues)';
  }
}
