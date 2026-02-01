import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:fmecg_mobile/components/ecg_chart_widget.dart';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/ecg_packet_parser.dart';
import 'package:fmecg_mobile/controllers/high_frequency_data_saver.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/repositories/ecg_records_repository.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BleLiveChart extends StatefulWidget {
  const BleLiveChart({Key? key, required this.bluetoothCharacteristic, required this.deviceConnected})
    : super(key: key);

  final QualifiedCharacteristic bluetoothCharacteristic;
  final DiscoveredDevice deviceConnected;

  @override
  State<BleLiveChart> createState() => _BleLiveChartState();
}

class _BleLiveChartState extends State<BleLiveChart> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<Queue<EcgDataPoint>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];

  late int count;
  List<bool> selectedChannels = [true, true, false, false, false, false];
  double timeWindowSeconds = 5.0;
  double samplingRateHz = 250.0;

  late StreamSubscription<List<int>> subscribeStream;
  List samples = [];
  bool isMeasuring = false;
  bool isUploaded = false;
  bool isCalculated = false;
  DateTime? startTime;

  File? _fileToSave;
  HighFrequencyDataSaver? _dataSaver;

  // API upload fields
  late EcgRecordsRepository _recordsRepository;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // ECG-style chart colors for different channels
  final List<Color> chartColors = [
    const Color(0xFF00FF41), // Bright green - classic ECG monitor color
    const Color(0xFF00D4FF), // Cyan blue
    const Color(0xFFFF6B35), // Orange red
    const Color(0xFFFFD23F), // Golden yellow
    const Color(0xFFFF3366), // Pink red
    const Color(0xFF9B59B6), // Purple
  ];

  // Channel names
  final List<String> channelNames = ["CH1", "CH2", "CH3", "CH4", "CH5", "CH6"];

  @override
  void initState() {
    super.initState();
    count = 0;
    _initializeChartData();

    // Initialize the API repository
    // Uses EnvConfig.apiBaseUrl from environment configuration
    _recordsRepository = EcgRecordsRepository();
  }

  @override
  void dispose() {
    super.dispose();
    _clearDataInChart();
    _dataSaver?.close();
    if (isMeasuring) {
      subscribeStream.cancel();
    }
  }

  void _initializeChartData() {
    channelChartData.clear();
    chartSeriesControllers.clear();
    crosshairBehaviors.clear();

    for (int i = 0; i < 6; i++) {
      channelChartData.add(Queue<EcgDataPoint>());
      chartSeriesControllers.add(null);
      crosshairBehaviors.add(
        CrosshairBehavior(
          enable: true,
          lineType: CrosshairLineType.vertical,
          activationMode: ActivationMode.none,
          lineColor: chartColors[i],
          lineWidth: 2,
        ),
      );
    }
  }

  List<int> get _getSelectedChannelIndices {
    List<int> indices = [];
    for (int i = 0; i < selectedChannels.length; i++) {
      if (selectedChannels[i]) {
        indices.add(i);
      }
    }
    return indices;
  }

  int get _numberOfSelectedChannels {
    return selectedChannels.where((selected) => selected).length;
  }

  _clearDataInChart({bool cancelStream = false}) {
    // Clear chart data first
    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
    }

    samples = [];
    count = 0;
    startTime = null;

    if (cancelStream && isMeasuring) {
      subscribeStream.cancel();
    }

    // Reset chart controllers to null to avoid disposed controller errors
    for (int i = 0; i < chartSeriesControllers.length; i++) {
      chartSeriesControllers[i] = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  _resetMeasuring() async {
    _clearDataInChart(cancelStream: true);

    // Close the data saver
    await _dataSaver?.close();
    _dataSaver = null;
    _fileToSave = null;

    if (mounted) {
      setState(() {
        isMeasuring = false;
        isCalculated = false;
      });
    }
  }

  Future<void> _initializeFileAndDataSaver() async {
    // Create a new file for this recording session
    _fileToSave = await FilesManagement.getFilePath();

    // Delete existing file and create a fresh one
    if (await _fileToSave!.exists()) {
      await _fileToSave!.delete();
    }
    await _fileToSave!.create(recursive: true);

    // Initialize the high-frequency data saver
    _dataSaver = HighFrequencyDataSaver(
      file: _fileToSave!,
      bufferSize: 250, // Flush every 1 second at 250Hz
      headers: const ['time', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6'],
    );
    await _dataSaver!.initialize();
  }

  _handleSaveRecordInFile() async {
    if (isMeasuring) {
      subscribeStream.cancel();
    }

    // Close the data saver to flush remaining data
    await _dataSaver?.close();
    _dataSaver = null;

    _clearDataInChart();

    if (mounted) {
      setState(() {
        samples.clear();
        isMeasuring = false;
      });
    }

    return Utils.showDialogWarningError(context, false, "Data saved successfully to ${_fileToSave?.path}");
  }

  Future<void> _uploadToServer() async {
    if (_fileToSave == null) {
      if (mounted) {
        Utils.showDialogWarningError(context, true, "No file to upload. Please save a recording first.");
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Prepare metadata
      final metadata = {
        'device_id': widget.deviceConnected.id,
        'device_name': widget.deviceConnected.name,
        'recorded_at': DateTime.now().toIso8601String(),
        'sampling_rate': samplingRateHz,
        'duration_seconds': timeWindowSeconds,
        'channels': selectedChannels.asMap().entries.where((e) => e.value).map((e) => channelNames[e.key]).toList(),
      };

      // Upload with progress tracking
      final record = await _recordsRepository.uploadRecording(
        file: _fileToSave!,
        metadata: metadata,
        onUploadProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
          isUploaded = true;
        });

        if (record != null) {
          Utils.showDialogWarningError(
            context,
            false,
            "Upload successful!\n\nRecord ID: ${record.id}\nFilename: ${record.filename}\nFile Size: ${(record.fileSize ?? 0) / 1024} KB",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        Utils.showDialogWarningError(context, true, "Upload failed: ${e.toString()}");
      }
    }
  }

  double _getCurrentTimeInSeconds() {
    if (startTime == null) return 0.0;
    return DateTime.now().difference(startTime!).inMilliseconds / 1000.0;
  }

  void _processBluetoothData(List<int> bluetoothPacket) {
    if (!mounted) return;

    try {
      List<double> channelDecimalValues = EcgPacketParser.processECGDataPacketFromBluetooth(bluetoothPacket);
      List<double> channelVoltageValues = EcgPacketParser.convertDecimalValuesToVoltageForDisplay(channelDecimalValues);

      final double currentTime = _getCurrentTimeInSeconds();

      // Save to CSV using the isolate-based saver (high frequency, non-blocking)
      _dataSaver?.addDataPoint(currentTime, channelDecimalValues);

      // Decimation: display every 10th sample (25Hz) for smoother UI
      if (count % 10 == 0) {
        _updateChartDataWithRealData(channelVoltageValues);
      }
    } catch (e) {
      print('Error processing Bluetooth data: $e');
    }
  }

  void _updateChartDataWithRealData(List<double> channelVoltageValues) {
    if (!mounted) return;

    final double currentTime = _getCurrentTimeInSeconds();
    final double maxTimeWindow = timeWindowSeconds;
    // Max display points = time window * display rate (25Hz after decimation by 10)
    final int maxDisplayPoints = (maxTimeWindow * samplingRateHz / 10).toInt();

    for (int i = 0; i < selectedChannels.length && i < channelVoltageValues.length; i++) {
      if (!selectedChannels[i]) continue;

      final newData = EcgDataPoint(currentTime, channelVoltageValues[i]);

      if (channelChartData[i].length >= maxDisplayPoints) {
        // Use removeFirst() for O(1) performance instead of removeAt(0)
        channelChartData[i].removeFirst();
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null && mounted) {
          try {
            chartSeriesControllers[i]!.updateDataSource(
              removedDataIndexes: <int>[0],
              addedDataIndexes: <int>[channelChartData[i].length - 1],
            );
          } catch (e) {
            print('Chart controller $i disposed, resetting to null');
            chartSeriesControllers[i] = null;
          }
        }
      } else {
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null && mounted) {
          try {
            chartSeriesControllers[i]!.updateDataSource(addedDataIndexes: <int>[channelChartData[i].length - 1]);
          } catch (e) {
            print('Chart controller $i disposed, resetting to null');
            chartSeriesControllers[i] = null;
          }
        }
      }
    }
  }

  Future<void> subscribeCharacteristic() async {
    startTime = DateTime.now();

    // Initialize file and data saver before starting measurement
    await _initializeFileAndDataSaver();

    subscribeStream = flutterReactiveBle.subscribeToCharacteristic(widget.bluetoothCharacteristic).listen((value) {
      count += 1;
      _processBluetoothData(value);
    });
  }

  Widget _buildCompactControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          // Channel selector - compact row
          Row(
            children: [
              Text("Channels:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: List.generate(6, (index) {
                    return InkWell(
                      onTap:
                          isMeasuring
                              ? null
                              : () {
                                setState(() {
                                  selectedChannels[index] = !selectedChannels[index];
                                  _clearDataInChart(cancelStream: false);
                                });
                              },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedChannels[index] ? chartColors[index].withOpacity(0.3) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: selectedChannels[index] ? chartColors[index] : Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          channelNames[index],
                          style: TextStyle(
                            color: selectedChannels[index] ? chartColors[index] : Colors.grey[700],
                            fontWeight: selectedChannels[index] ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time window and controls row
          Row(
            children: [
              Text("Window:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<double>(
                  value: timeWindowSeconds,
                  isDense: true,
                  underline: Container(),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  items:
                      [
                        5.0,
                        10.0,
                        15.0,
                        20.0,
                        30.0,
                      ].map((seconds) => DropdownMenuItem(value: seconds, child: Text("${seconds.toInt()}s"))).toList(),
                  onChanged: (value) {
                    if (value != null && !isMeasuring) {
                      setState(() {
                        timeWindowSeconds = value;
                        _clearDataInChart();
                      });
                    }
                  },
                ),
              ),
              const Spacer(),
              // Show recording indicator if data saver is active
              if (_dataSaver?.isInitialized == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('REC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red[700])),
                    ],
                  ),
                ),
              // Control buttons - compact
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMeasuring ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
                onPressed:
                    _numberOfSelectedChannels > 0
                        ? () async {
                          if (isMeasuring) {
                            await _resetMeasuring();
                          } else {
                            setState(() {
                              isMeasuring = true;
                            });
                            await subscribeCharacteristic();
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          }
                        }
                        : null,
                child: Text(
                  isMeasuring ? 'Stop' : 'Start',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: _dataSaver?.isInitialized == true ? _handleSaveRecordInFile : null,
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: _fileToSave != null && !_isUploading && !isMeasuring ? _uploadToServer : null,
                child:
                    _isUploading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : const Text('Upload', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ],
              ),
            ),
          if (_numberOfSelectedChannels == 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text("Select at least one channel", style: TextStyle(color: Colors.red[600], fontSize: 11)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double width = orientation == Orientation.portrait ? size.width : size.height;
    final List<int> selectedChannelIndices = _getSelectedChannelIndices;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(PhosphorIcons.regular.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: Text(S.current.measurementPage),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          children: [
            // Compact controls
            _buildCompactControls(),

            // Charts - maximized space
            Expanded(
              child:
                  selectedChannelIndices.isEmpty
                      ? Center(
                        child: Text(
                          "Please select at least one channel to display",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                      : SingleChildScrollView(
                        child: Column(
                          children:
                              selectedChannelIndices
                                  .map(
                                    (channelIndex) => Container(
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.15),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SizedBox(
                                          width: width - 20,
                                          height:
                                              _numberOfSelectedChannels == 1
                                                  ? size.height *
                                                      0.7 // Use 70% of screen height for single chart
                                                  : (_numberOfSelectedChannels <= 2
                                                      ? size.height *
                                                          0.35 // Use 35% for 2 charts
                                                      : size.height * 0.25), // Use 25% for 3+ charts
                                          // RepaintBoundary isolates chart repaints from rest of UI
                                          child: RepaintBoundary(
                                            child: ECGChartWidget(
                                              channelIndex: channelIndex,
                                              legendTitle: channelNames[channelIndex],
                                              chartColor: chartColors[channelIndex],
                                              chartData: channelChartData[channelIndex].toList(),
                                              crosshairBehavior: crosshairBehaviors[channelIndex],
                                              timeWindowSeconds: timeWindowSeconds,
                                              onRendererCreated: (controller) {
                                                if (mounted) {
                                                  chartSeriesControllers[channelIndex] = controller;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
