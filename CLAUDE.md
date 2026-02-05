# fmECG Mobile

A Flutter-based mobile application for ECG (Electrocardiogram) data monitoring and management, part of the SPARC fmECG system.

## Project Overview

**Purpose:** Mobile client for monitoring cardiac health data with real-time ECG visualization and Bluetooth device connectivity.

**Key Features:**
- Real-time ECG data visualization (6-channel)
- Bluetooth Low Energy connectivity to ECG hardware
- ECG data recording, upload, and retrieval
- User authentication with JWT tokens
- Firebase push notifications
- Multi-language support (English, Vietnamese)

**Version:** 1.2.1+27

## Tech Stack

- **Framework:** Flutter 3.24.4+ / Dart 3.7.0+
- **State Management:** Provider + BLoC
- **HTTP Client:** Dio with token interceptors
- **API Generation:** OpenAPI Generator
- **Charts:** Syncfusion Flutter Charts
- **Bluetooth:** flutter_reactive_ble, flutter_blue_plus
- **Storage:** SharedPreferences
- **Notifications:** Firebase Cloud Messaging

## Project Structure

```
lib/
├── main.dart                 # Entry point, Firebase & Provider setup
├── app.dart                  # Main app widget and navigation
├── config/
│   └── env_config.dart       # Environment configuration (local/dev/prod)
├── providers/                # State management (ChangeNotifier)
│   ├── auth_provider.dart    # Authentication, tokens
│   ├── ecg_provider.dart     # ECG data state
│   └── bluetooth_provider.dart
├── controllers/              # Business logic
│   ├── ecg_record_controller.dart
│   └── ecg_packet_parser.dart  # BLE packet parsing
├── repositories/             # API abstraction layer
├── networks/
│   └── http_dio.dart         # Dio configuration, interceptors
├── screens/                  # UI screens by feature
├── components/               # Reusable UI components
├── models/                   # Data models
├── utils/                    # Utility functions
├── openapi/
│   └── api_spec.yaml         # OpenAPI specification
└── l10n/                     # Localization strings

api/fmecg_api/                # Generated OpenAPI client
```

## Development Commands

```bash
# Run with different environments (via mise)
mise run local   # Local API: http://localhost:4000
mise run dev     # Dev API: http://103.200.20.59:3000
mise run prod    # Production API: https://api.fmecg.com

# Build APKs
mise run build:local
mise run build:dev
mise run build:prod

# Code generation (after modifying openapi/api_spec.yaml)
flutter pub run build_runner build

# Analyze code
flutter analyze
```

**Requirements:** Flutter 3.24.4+, Java 17 (Android builds)

## Code Conventions

**Naming:**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`

**Architecture:**
- Provider pattern for state management
- Repository pattern for API abstraction
- Controller pattern for business logic
- Component-based UI with Material Design 3

**Style:**
- Line width: 120 characters
- Prefer `const` constructors
- Font: Inter

## API Integration

**Authentication Flow:**
1. Login via `AuthProvider.login()` → receives JWT tokens
2. Tokens stored in SharedPreferences
3. Dio interceptor adds `Authorization: Bearer {token}` header
4. Auto-refresh on token expiry (15-min validity)

**Environment Configuration:**
- Set via `--dart-define=ENV=local|dev|prod` at compile time
- Base URL read from `EnvConfig.apiUrl`

**Dio Timeouts:**
- Connection: 8s
- Send: 15s
- Receive: 20s

## State Management

```dart
// Provider definition
class ECGProvider extends ChangeNotifier {
  List ecgRecordsPreview = [];

  setECGRecordsPreview(List data) {
    ecgRecordsPreview = data;
    notifyListeners();
  }
}

// Usage in UI
Consumer<ECGProvider>(
  builder: (ctx, ecgProvider, _) => ListView(...)
)
```

**Available Providers:**
- `AuthProvider` - Auth state, tokens, theme
- `UserProvider` - Current user data
- `ECGProvider` - ECG records state
- `EcgRecordsProvider` - Upload progress
- `BluetoothProvider` - BLE device state
- `NewsProvider` - News feed

## Bluetooth Protocol

**BLE UUIDs (Nordic UART Service):**
- Service: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- RX: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- TX: `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`

**Packet Format (22 bytes):**
- Status: 3 bytes
- Channel data: 18 bytes (6 channels x 3 bytes)
- Count: 1 byte

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization, providers setup |
| `lib/config/env_config.dart` | Environment-specific configuration |
| `lib/networks/http_dio.dart` | HTTP client with auth interceptor |
| `lib/providers/auth_provider.dart` | Authentication logic |
| `lib/controllers/ecg_packet_parser.dart` | BLE data parsing |
| `lib/openapi/api_spec.yaml` | API specification |
| `mise.toml` | Task runner configuration |

## Testing

```bash
flutter test
```

Testing infrastructure is minimal. Unit tests can be added in the `/test` directory.

## Localization

Supported: English (`en`), Vietnamese (`vi`)

Usage: `S.current.{key}` for localized strings.

## Notes

- ECG data is saved as CSV using isolates for non-blocking I/O
- High-frequency data handler in `high_frequency_data_saver.dart`
- Global context accessible via `Utils.globalContext`
- Generated files excluded from linting: `*.g.dart`, `*.freezed.dart`, `lib/generated/**`
