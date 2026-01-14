import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// Message types for isolate communication
enum _MessageType { initialize, addData, flush, close }

/// Configuration for initializing the isolate
class _IsolateConfig {
  final SendPort sendPort;
  final String filePath;
  final List<String> headers;

  _IsolateConfig(this.sendPort, this.filePath, this.headers);
}

/// Message to send data to the isolate
class _DataMessage {
  final _MessageType type;
  final double? time;
  final Float64List? channelValues;

  _DataMessage.initialize() : type = _MessageType.initialize, time = null, channelValues = null;
  _DataMessage.addData(this.time, this.channelValues) : type = _MessageType.addData;
  _DataMessage.flush() : type = _MessageType.flush, time = null, channelValues = null;
  _DataMessage.close() : type = _MessageType.close, time = null, channelValues = null;
}

/// High-frequency data saver that runs file I/O in a separate isolate
/// to prevent blocking the main UI thread.
///
/// Optimized for 6-channel ECG data at 250Hz sampling rate.
/// Uses typed Float64List for memory efficiency.
class HighFrequencyDataSaver {
  static const int channelCount = 6;
  static const int defaultBufferSize = 250; // 1 second at 250Hz

  final File file;
  final int bufferSize;
  final List<String> headers;

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool _isInitialized = false;

  // Pre-allocated typed array for sending data (avoids creating new objects each call)
  final Float64List _channelBuffer = Float64List(channelCount);

  HighFrequencyDataSaver({
    required this.file,
    this.bufferSize = defaultBufferSize,
    this.headers = const ['time', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6'],
  });

  /// Check if the saver is initialized and ready to receive data
  bool get isInitialized => _isInitialized;

  /// Initialize the isolate and prepare for data collection
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_isolateEntryPoint, _IsolateConfig(_receivePort!.sendPort, file.path, headers));

    // Wait for the isolate to send back its SendPort
    final completer = Completer<SendPort>();
    _receivePort!.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      } else if (message is String) {
        // Log messages from isolate for debugging
        print('[HighFrequencyDataSaver Isolate] $message');
      }
    });

    _sendPort = await completer.future;
    _isInitialized = true;
    print('[HighFrequencyDataSaver] Initialized successfully');
  }

  /// Add a single data point with timestamp and 6 channel values
  ///
  /// [time] - timestamp in seconds
  /// [channelDecimalValues] - list of 6 decimal values from ECG channels
  ///
  /// This method is designed to be called at 250Hz without blocking the UI
  void addDataPoint(double time, List<double> channelDecimalValues) {
    if (!_isInitialized || _sendPort == null) {
      return;
    }

    // Copy values to pre-allocated typed array
    for (int i = 0; i < channelCount && i < channelDecimalValues.length; i++) {
      _channelBuffer[i] = channelDecimalValues[i];
    }

    // Fill remaining channels with 0 if less than 6 values provided
    for (int i = channelDecimalValues.length; i < channelCount; i++) {
      _channelBuffer[i] = 0.0;
    }

    // Send a copy of the buffer to the isolate
    _sendPort!.send(_DataMessage.addData(time, Float64List.fromList(_channelBuffer)));
  }

  /// Add a single data point using a pre-allocated Float64List
  ///
  /// [time] - timestamp in seconds
  /// [channelDecimalValues] - Float64List of 6 decimal values from ECG channels
  ///
  /// More efficient version when you already have a Float64List
  void addDataPointTyped(double time, Float64List channelDecimalValues) {
    if (!_isInitialized || _sendPort == null) {
      return;
    }

    // Send a copy to the isolate
    _sendPort!.send(_DataMessage.addData(time, Float64List.fromList(channelDecimalValues)));
  }

  /// Force flush any buffered data to disk
  Future<void> flush() async {
    if (!_isInitialized || _sendPort == null) {
      return;
    }

    _sendPort!.send(_DataMessage.flush());
  }

  /// Close the saver, flush remaining data, and clean up resources
  Future<void> close() async {
    if (!_isInitialized) {
      return;
    }

    _sendPort?.send(_DataMessage.close());

    // Give the isolate time to finish writing
    await Future.delayed(const Duration(milliseconds: 100));

    _isolate?.kill(priority: Isolate.beforeNextEvent);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
    _isInitialized = false;

    print('[HighFrequencyDataSaver] Closed successfully');
  }

  /// Static entry point for the isolate
  static void _isolateEntryPoint(_IsolateConfig config) {
    final receivePort = ReceivePort();
    config.sendPort.send(receivePort.sendPort);

    IOSink? sink;
    final List<String> buffer = [];
    final int bufferSize = defaultBufferSize;

    // Open file and write headers
    try {
      final file = File(config.filePath);
      final bool fileExists = file.existsSync();
      final bool fileIsEmpty = !fileExists || file.lengthSync() == 0;

      sink = file.openWrite(mode: FileMode.append);

      if (fileIsEmpty) {
        sink.writeln(config.headers.join(','));
      }

      config.sendPort.send('File opened: ${config.filePath}');
    } catch (e) {
      config.sendPort.send('Error opening file: $e');
      return;
    }

    void flushBuffer() {
      if (buffer.isEmpty || sink == null) return;

      final StringBuffer sb = StringBuffer();
      for (final line in buffer) {
        sb.writeln(line);
      }
      sink.write(sb.toString());
      buffer.clear();
    }

    receivePort.listen((message) async {
      if (message is _DataMessage) {
        switch (message.type) {
          case _MessageType.addData:
            if (message.time != null && message.channelValues != null) {
              // Format: time,ch1,ch2,ch3,ch4,ch5,ch6
              final StringBuffer line = StringBuffer();
              line.write(message.time!.toStringAsFixed(6));
              for (int i = 0; i < channelCount; i++) {
                line.write(',');
                line.write(message.channelValues![i].toStringAsFixed(6));
              }
              buffer.add(line.toString());

              // Flush when buffer is full
              if (buffer.length >= bufferSize) {
                flushBuffer();
              }
            }
            break;

          case _MessageType.flush:
            flushBuffer();
            await sink?.flush();
            config.sendPort.send('Buffer flushed');
            break;

          case _MessageType.close:
            flushBuffer();
            await sink?.flush();
            await sink?.close();
            config.sendPort.send('File closed');
            receivePort.close();
            break;

          case _MessageType.initialize:
            // Already initialized
            break;
        }
      }
    });
  }
}
