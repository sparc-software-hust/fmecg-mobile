# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for collecting, visualizing, and managing ECG (Electrocardiogram) data from Bluetooth Low Energy (BLE) enabled ECG devices. The app supports both real hardware mode and a demo/simulation mode for testing without physical devices.

## Development Environment Requirements

- **Flutter version**: 3.24.4
- **Dart SDK**: >=3.7.0 <4.0.0
- **Java version**: 17 (for Android builds)
- **JAVA_HOME**: Must be configured in `android/gradle.properties` (see file comments for platform-specific examples)

## Essential Commands

### Building

```bash
# Build Android App Bundle (for Play Store)
flutter build appbundle --no-tree-shake-icons

# Build APK (for direct installation)
flutter build apk --no-tree-shake-icons

# Build for iOS
flutter build ios
```

### Running

```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device_id>

# Hot reload during development: Press 'r'
# Hot restart: Press 'R'
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/record_count_test.dart
```

### Development Tools

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Clean build artifacts
flutter clean
```

### Localization

```bash
# Generate localization files (after modifying .arb files)
flutter pub run intl_utils:generate
```

## Architecture Overview

### State Management: Provider Pattern

The app uses the Provider pattern with 5 main providers initialized in `main.dart`:

1. **AuthProvider** - Authentication (login/logout/register), JWT token management
2. **UserProvider** - Current user information and persistence
3. **NewsProvider** - News/notifications from backend
4. **BluetoothProvider** - BLE device connection state (DiscoveredDevice, QualifiedCharacteristic)
5. **ECGProvider** - ECG record data for historical display

All providers are ChangeNotifiers accessible throughout the widget tree via `Provider.of<T>(context)` or `context.watch<T>()`.

### Project Structure

- `lib/main.dart` - App entry point with MultiProvider setup
- `lib/app.dart` - Main navigation hub (Demo Mode vs Bluetooth Mode)
- `lib/providers/` - State management (5 providers)
- `lib/controllers/` - Business logic, data processing, packet parsing
- `lib/models/` - Data models (User, ECG Record, Session, etc.)
- `lib/screens/` - UI screens organized by feature area
- `lib/components/` - Reusable widgets (charts, buttons, avatars)
- `lib/utils/` - File management, CSV parsing, platform-specific utilities
- `lib/networks/` - HTTP/Dio API client configuration
- `lib/constants/` - API endpoints, colors, Firebase config

### Bluetooth/BLE Architecture

**Service UUIDs** (Nordic UART Service):
- Service: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- RX Characteristic: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- TX Characteristic: `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`

**BLE Connection Flow:**
1. `BleReactiveScreen` - Check BLE adapter status
2. `BleConnectionScreen` - Scan for devices (filter RSSI > -90)
3. Connect to device → Create QualifiedCharacteristic
4. `BleLiveChart` - Subscribe to TX characteristic for data stream

**Data Flow:**
```
BLE Device (250Hz, 22-byte packets)
    ↓
EcgPacketParser.processECGDataPacketFromBluetooth()
├─→ Extract 6 channels (3 bytes each, 24-bit signed integers)
├─→ Convert to voltage: (decimal × 4.5V) / (2^23 - 1)
    ↓
    ├─→ HighFrequencyDataSaver (Isolate) → CSV file (buffered writes)
    └─→ Chart Update (every 5th sample = 50Hz display) → UI
```

### ECG Data Packet Structure (22 bytes)

- Bytes 0-2: Status bytes (3 bytes)
- Bytes 3-20: Channel data (18 bytes = 6 channels × 3 bytes each)
- Byte 21: Count byte (1 byte)

Each channel value is a 24-bit signed integer (two's complement) representing voltage.

### File Persistence Strategy

**Storage Locations:**
- **Android**: `/storage/self/primary/fmecg/records/`
- **iOS**: `Application Documents Directory/records/`

**File Naming Convention:**
```
Format: dd-MM-yyyy-H-m-ss.csv
Example: 19-01-2026-14-30-45.csv
```

**CSV Structure:**
```
time,ch1,ch2,ch3,ch4,ch5,ch6
0.000000,1234.567890,2345.678901,...
0.004000,1235.567890,2346.678901,...
```

Time in seconds (6 decimals), channel values are voltage decimals (6 decimals).

**Critical Performance Feature - Isolate-Based Writing:**
`HighFrequencyDataSaver` runs file I/O in a separate Dart Isolate to prevent UI blocking:
- Buffers 250 samples (~1 second at 250Hz)
- Batch writes to disk using StringBuffer
- Uses Float64List typed arrays for memory efficiency

### Chart Visualization: Two Modes

**LiveChartDemo** (`lib/components/live_chart_demo.dart`):
- Demo/testing mode with simulated ECG data
- Timer-based synthetic sine waves with noise
- No BLE dependency - runs standalone
- Launched from main menu "Demo Mode" button

**BleLiveChart** (`lib/screens/bluetooth_screens/ble_live_chart.dart`):
- Real ECG device data collection
- BLE characteristic subscription
- EcgPacketParser processes real packets
- Launched after successful BLE connection

**Shared Features:**
- 6-channel ECG visualization (user-toggleable channels)
- Configurable time window (5s, 10s, 15s, 20s, 30s)
- Syncfusion FastLineSeries for performance
- Identical UI layout and ECGChartWidget component
- Same HighFrequencyDataSaver for file saving

### Performance Optimizations

1. **Isolate-based file I/O** - Non-blocking writes via separate thread
2. **Typed arrays** - Float64List reduces memory allocations
3. **Chart decimation** - Display every 5th sample (50Hz) while recording at 250Hz
4. **Buffered writing** - Batch 250 samples before disk write
5. **FastLineSeries** - Syncfusion's optimized chart for real-time data
6. **Pre-allocated buffers** - Reuse Float64List instances

## Key Dependencies

- **flutter_reactive_ble** (v5.1.1) - BLE communication
- **provider** (v6.0.5) - State management
- **syncfusion_flutter_charts** (v31.2.5) - High-performance charting
- **path_provider** (v2.0.15) - File system access
- **shared_preferences** (v2.1.1) - Local key-value storage
- **dio** (v5.1.2) - HTTP client for API calls
- **firebase_messaging** (v15.1.6) - Push notifications
- **permission_handler** (v12.0.1) - Runtime permissions

## Backend API

Base URL: `http://103.200.20.59:3003`

Used for:
- User authentication (login/logout/register)
- User profile management
- News/notifications

API client configured in `lib/networks/http_dio.dart` using Dio.

## Important File Locations

- **Secrets/Config**: `lib/certs/secrets.dart` - Contains sensitive configuration
- **Firebase Config**: `lib/firebase_options.dart` - Generated Firebase configuration
- **Localization**: `lib/generated/l10n.dart` - Auto-generated from .arb files
- **Theme**: `lib/constants/theme.dart` - App-wide theme definitions
- **Colors**: `lib/constants/color_constant.dart` - Color palette

## Navigation Pattern

The app uses **imperative navigation** with MaterialPageRoute (no named routes):

```
App (MainScreen)
├─→ Demo Mode → LiveChartDemo
└─→ Bluetooth Mode → BleReactiveScreen
                        ↓
                    BleConnectionScreen (scan/connect)
                        ↓
                    BleLiveChart (measure & record)
```

## Platform-Specific Considerations

### Android
- Requires Bluetooth permissions in AndroidManifest.xml
- Storage permissions for file saving
- Minimum SDK version defined in `android/app/build.gradle`
- Must configure `JAVA_HOME` in `android/gradle.properties` for Java 17

### iOS
- Bluetooth permissions in Info.plist
- File Provider configuration for document access
- Deployment target defined in `ios/Podfile`

## Common Development Patterns

### Adding a New Screen with Provider Data

```dart
import 'package:provider/provider.dart';
import 'package:fmecg_mobile/providers/ecg_provider.dart';

class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ecgProvider = Provider.of<ECGProvider>(context);
    // Or use: context.watch<ECGProvider>()

    return Scaffold(
      body: // Your UI using ecgProvider data
    );
  }
}
```

### Working with BLE Data

When modifying BLE data processing:
1. Packet parsing logic is in `lib/controllers/ecg_packet_parser.dart`
2. File saving uses `lib/controllers/high_frequency_data_saver.dart` (Isolate-based)
3. Chart updates happen in `BleLiveChart` or `LiveChartDemo`
4. Always test with both Demo Mode and real BLE device

### File Operations

Use `lib/utils/platform_file_saver.dart` for cross-platform file operations:
```dart
final directory = await PlatformFileSaver.getRecordsDirectory();
final filePath = FilesManagement.generateFilePath(directory);
```

### CSV Data Handling

Use `lib/utils/csv_parser.dart` for reading/writing CSV files:
```dart
// Writing
final rows = [['time', 'ch1', 'ch2', ...]];
await CsvParser.writeData(filePath, rows);

// Reading
final data = await CsvParser.parseFile(filePath);
```

## Testing Guidelines

- Tests are located in `test/` directory
- Currently minimal test coverage - when adding tests, focus on:
  - Data parsing logic (EcgPacketParser)
  - File I/O operations (HighFrequencyDataSaver)
  - Provider state changes
  - CSV parsing/writing utilities

## Debugging Tips

### BLE Connection Issues
1. Check BLE adapter status in `BleReactiveScreen`
2. Verify device RSSI > -90 during scanning
3. Ensure correct service/characteristic UUIDs
4. Check Bluetooth permissions are granted

### File Saving Issues
1. Verify storage permissions granted
2. Check records directory exists (created automatically)
3. Review Isolate logs in `HighFrequencyDataSaver`
4. Confirm platform-specific paths are correct

### Chart Performance
1. Ensure chart updates every 5th sample (not every sample)
2. Check sliding window size isn't too large
3. Verify FastLineSeries is being used (not LineSeries)
4. Monitor memory usage with large datasets

## Known Configuration Notes

- The `--no-tree-shake-icons` flag is required for builds to prevent icon issues
- Firebase configuration is platform-specific (check `firebase_options.dart`)
- Localization supports English ('en') and Vietnamese ('vi')
- App uses Material3 design with custom 'Inter' font family
