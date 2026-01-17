  Detailed Step-by-Step Migration Plan

  Phase 1: Foundation Setup

  Step 1: Create New Folder Structure

  lib/
  ├── core/
  │   ├── constants/
  │   ├── utils/
  │   ├── services/
  │   └── config/
  ├── data/
  │   ├── models/
  │   ├── repositories/
  │   └── data_sources/
  │       ├── remote/
  │       └── local/
  ├── domain/
  │   ├── usecases/
  │   │   ├── auth/
  │   │   ├── bluetooth/
  │   │   └── ecg/
  │   └── parsers/
  └── presentation/
      ├── viewmodels/
      │   ├── auth/
      │   ├── bluetooth/
      │   ├── ecg/
      │   └── user/
      ├── screens/
      │   ├── auth/
      │   ├── bluetooth/
      │   ├── measurement/
      │   └── home/
      └── widgets/
          ├── common/
          └── charts/

  Actions:
  - Create all folders above
  - Keep existing folders temporarily for reference

  ---
  Step 2: Set Up Core Layer

  Move/Refactor Constants:
  - constants/api_constant.dart → core/constants/api_constants.dart
  - constants/color_constant.dart + constants/theme.dart → core/constants/theme_constants.dart
  - constants/firebase_constant.dart → Keep or move to core/config/firebase_config.dart

  Refactor Utils:
  - utils/files_management.dart → core/utils/file_manager.dart
  - utils/validation.dart → core/utils/validation_helper.dart
  - utils/utils.dart → Split into smaller utilities in core/utils/
  - utils/csv_parser.dart → core/utils/csv_parser.dart

  Create Services:
  Create core/services/storage_service.dart:
  class StorageService {
    static const String _keyAccessToken = 'access_token';
    static const String _keyRefreshToken = 'refresh_token';
    // ... other keys

    Future<void> saveToken(String token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, token);
    }

    Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAccessToken);
    }
    // ... other storage methods
  }

  Create Config:
  - Move networks/http_dio.dart → core/config/dio_config.dart
  - Refactor to return configured Dio instance

  ---
  Phase 2: Data Layer Migration

  Step 3: Create Data Layer Structure

  Models (keep existing, just move):
  - models/user_model.dart → data/models/user_model.dart
  - models/ecg_record_model.dart → data/models/ecg_record_model.dart
  - Create data/models/bluetooth_device_model.dart (for BLE device info)
  - Create data/models/auth_response_model.dart (for login/signup response)

  ---
  Step 4: Migrate Auth Data Layer

  Create data/data_sources/remote/auth_api.dart:
  class AuthApi {
    final Dio _dio;

    AuthApi(this._dio);

    Future<AuthResponseModel> login({
      required String email,
      required String password,
    }) async {
      final response = await _dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'email': email,
          'password': password,
        }),
      );
      return AuthResponseModel.fromJson(response.data);
    }

    Future<AuthResponseModel> refreshToken(String refreshToken) async {
      // Implementation
    }

    Future<void> logout() async {
      // Implementation
    }
  }

  Create data/data_sources/local/auth_local_storage.dart:
  class AuthLocalStorage {
    final StorageService _storage;

    AuthLocalStorage(this._storage);

    Future<void> saveAuthData({
      required String accessToken,
      required String refreshToken,
      required DateTime expiryDate,
      required UserModel user,
    }) async {
      await _storage.saveToken(accessToken);
      await _storage.saveRefreshToken(refreshToken);
      await _storage.saveExpiryDate(expiryDate);
      await _storage.saveUserInfo(jsonEncode(user.toJson()));
    }

    Future<Map<String, dynamic>?> getAuthData() async {
      final token = await _storage.getToken();
      if (token == null) return null;

      return {
        'accessToken': token,
        'refreshToken': await _storage.getRefreshToken(),
        'expiryDate': await _storage.getExpiryDate(),
        'user': await _storage.getUserInfo(),
      };
    }

    Future<void> clearAuthData() async {
      await _storage.clearAll();
    }
  }

  Create data/repositories/auth_repository.dart:
  class AuthRepository {
    final AuthApi _authApi;
    final AuthLocalStorage _localStorage;

    AuthRepository(this._authApi, this._localStorage);

    Future<UserModel> login({
      required String email,
      required String password,
    }) async {
      // Call API
      final response = await _authApi.login(email: email, password: password);

      // Save to local storage
      await _localStorage.saveAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiryDate: response.expiryDate,
        user: response.user,
      );

      return response.user;
    }

    Future<bool> isAuthenticated() async {
      final authData = await _localStorage.getAuthData();
      if (authData == null) return false;

      final expiryDate = authData['expiryDate'] as DateTime;
      return DateTime.now().isBefore(expiryDate);
    }

    Future<void> logout() async {
      await _authApi.logout();
      await _localStorage.clearAuthData();
    }

    Future<String?> getAccessToken() async {
      final authData = await _localStorage.getAuthData();
      return authData?['accessToken'];
    }
  }

  ---
  Step 5: Migrate Bluetooth Data Layer

  Create data/models/bluetooth_device_model.dart:
  class BluetoothDeviceModel {
    final String id;
    final String name;
    final int rssi;
    final bool isConnected;

    BluetoothDeviceModel({
      required this.id,
      required this.name,
      required this.rssi,
      this.isConnected = false,
    });

    // Factory from DiscoveredDevice
    factory BluetoothDeviceModel.fromDiscoveredDevice(DiscoveredDevice device) {
      return BluetoothDeviceModel(
        id: device.id,
        name: device.name,
        rssi: device.rssi,
      );
    }
  }

  Create data/data_sources/ble_data_source.dart:
  class BleDataSource {
    final FlutterReactiveBle _ble;

    BleDataSource(this._ble);

    Stream<DiscoveredDevice> scanForDevices({
      required List<Uuid> serviceIds,
    }) {
      return _ble.scanForDevices(
        withServices: serviceIds,
        scanMode: ScanMode.lowLatency,
      );
    }

    Stream<ConnectionStateUpdate> connectToDevice(String deviceId) {
      return _ble.connectToDevice(id: deviceId);
    }

    Stream<List<int>> subscribeToCharacteristic(
      QualifiedCharacteristic characteristic,
    ) {
      return _ble.subscribeToCharacteristic(characteristic);
    }

    Future<void> disconnect(String deviceId) async {
      // Implementation
    }
  }

  Create data/repositories/bluetooth_repository.dart:
  class BluetoothRepository {
    final BleDataSource _bleDataSource;

    BluetoothRepository(this._bleDataSource);

    Stream<List<BluetoothDeviceModel>> scanForDevices() {
      return _bleDataSource
          .scanForDevices(serviceIds: [/* your service UUIDs */])
          .map((device) => BluetoothDeviceModel.fromDiscoveredDevice(device))
          .scan<List<BluetoothDeviceModel>>(
            [],
            (accumulated, current) => [...accumulated, current],
          );
    }

    Stream<bool> connectToDevice(String deviceId) {
      return _bleDataSource.connectToDevice(deviceId).map((state) {
        return state.connectionState == DeviceConnectionState.connected;
      });
    }

    Stream<List<int>> getEcgDataStream(
      QualifiedCharacteristic characteristic,
    ) {
      return _bleDataSource.subscribeToCharacteristic(characteristic);
    }
  }

  ---
  Step 6: Migrate ECG Measurement Data Layer

  Create data/data_sources/remote/ecg_api.dart:
  class EcgApi {
    final Dio _dio;

    EcgApi(this._dio);

    Future<List<EcgRecordModel>> getRecords(String userId) async {
      final response = await _dio.get('/ecg-records/patient/$userId');
      return (response.data as List)
          .map((json) => EcgRecordModel.fromJson(json))
          .toList();
    }

    Future<Map<String, dynamic>> getRecordData(String recordId) async {
      final response = await _dio.get('/ecg-records/record-data/$recordId');
      return response.data;
    }

    Future<void> uploadRecord(File file, Map<String, dynamic> metadata) async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        ...metadata,
      });

      await _dio.post('/api/record', data: formData);
    }
  }

  Create data/data_sources/local/ecg_local_storage.dart:
  class EcgLocalStorage {
    final FileManager _fileManager;
    final CsvParser _csvParser;

    EcgLocalStorage(this._fileManager, this._csvParser);

    Future<File> saveRecordToFile({
      required String fileName,
      required List<Map<String, dynamic>> data,
    }) async {
      final directory = await _fileManager.getRecordsDirectory();
      final filePath = '${directory.path}/$fileName';

      return await _csvParser.writeCsvFile(
        filePath: filePath,
        data: data,
        headers: ['time', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6'],
      );
    }

    Future<List<Map<String, dynamic>>> loadRecordFromFile(String filePath) async {
      return await _csvParser.readCsvFile(filePath);
    }

    Future<List<String>> getAllRecordFiles() async {
      final directory = await _fileManager.getRecordsDirectory();
      final files = directory.listSync();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.csv'))
          .map((file) => file.path)
          .toList();
    }
  }

  Create data/repositories/ecg_repository.dart:
  class EcgRepository {
    final EcgApi _ecgApi;
    final EcgLocalStorage _localStorage;

    EcgRepository(this._ecgApi, this._localStorage);

    Future<List<EcgRecordModel>> getRecords(String userId) async {
      return await _ecgApi.getRecords(userId);
    }

    Future<Map<String, dynamic>> getRecordData(String recordId) async {
      return await _ecgApi.getRecordData(recordId);
    }

    Future<File> saveRecordLocally({
      required List<Map<String, dynamic>> data,
    }) async {
      final fileName = _generateFileName();
      return await _localStorage.saveRecordToFile(
        fileName: fileName,
        data: data,
      );
    }

    Future<void> uploadRecord(File file, Map<String, dynamic> metadata) async {
      await _ecgApi.uploadRecord(file, metadata);
    }

    Future<List<String>> getAllLocalRecords() async {
      return await _localStorage.getAllRecordFiles();
    }

    String _generateFileName() {
      final now = DateTime.now();
      return '${now.day}-${now.month}-${now.year}-${now.hour}-${now.minute}-${now.second}.csv';
    }
  }

  ---
  Phase 3: Domain Layer (Optional but Recommended)

  Step 7: Create Use Cases

  Use cases encapsulate single business operations.

  Create domain/usecases/auth/login_usecase.dart:
  class LoginUseCase {
    final AuthRepository _repository;

    LoginUseCase(this._repository);

    Future<UserModel> execute({
      required String email,
      required String password,
    }) async {
      // Validation
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }
      if (password.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      // Business logic
      return await _repository.login(email: email, password: password);
    }

    bool _isValidEmail(String email) {
      return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    }
  }

  Create domain/usecases/bluetooth/scan_devices_usecase.dart:
  class ScanDevicesUseCase {
    final BluetoothRepository _repository;

    ScanDevicesUseCase(this._repository);

    Stream<List<BluetoothDeviceModel>> execute() {
      return _repository.scanForDevices();
    }
  }

  Create domain/usecases/bluetooth/parse_ecg_data_usecase.dart:
  class ParseEcgDataUseCase {
    final EcgPacketParser _parser;

    ParseEcgDataUseCase(this._parser);

    Map<String, List<double>> execute(List<int> rawData) {
      return _parser.parsePacket(rawData);
    }
  }

  Move parsers:
  - controllers/ecg_packet_parser.dart → domain/parsers/ecg_packet_parser.dart
  - controllers/high_frequency_data_saver.dart → domain/parsers/high_frequency_data_saver.dart

  ---
  Phase 4: Presentation Layer - ViewModels

  Step 8-11: Create ViewModels

  Create presentation/viewmodels/auth/auth_viewmodel.dart:
  class AuthViewModel extends ChangeNotifier {
    final LoginUseCase _loginUseCase;
    final AuthRepository _authRepository;

    AuthViewModel(this._loginUseCase, this._authRepository);

    // State
    UserModel? _user;
    bool _isLoading = false;
    String? _errorMessage;

    // Getters
    UserModel? get user => _user;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    bool get isAuthenticated => _user != null;

    // Methods
    Future<void> login(String email, String password) async {
      _setLoading(true);
      _clearError();

      try {
        _user = await _loginUseCase.execute(
          email: email,
          password: password,
        );
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      } finally {
        _setLoading(false);
      }
    }

    Future<void> logout() async {
      await _authRepository.logout();
      _user = null;
      notifyListeners();
    }

    Future<void> checkAuthStatus() async {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        // Load user data from storage
        final authData = await _authRepository._localStorage.getAuthData();
        // Set user
      }
      notifyListeners();
    }

    void _setLoading(bool value) {
      _isLoading = value;
      notifyListeners();
    }

    void _clearError() {
      _errorMessage = null;
    }
  }

  Create presentation/viewmodels/bluetooth/bluetooth_viewmodel.dart:
  class BluetoothViewModel extends ChangeNotifier {
    final ScanDevicesUseCase _scanDevicesUseCase;
    final BluetoothRepository _bluetoothRepository;
    final ParseEcgDataUseCase _parseEcgDataUseCase;

    BluetoothViewModel(
      this._scanDevicesUseCase,
      this._bluetoothRepository,
      this._parseEcgDataUseCase,
    );

    // State
    List<BluetoothDeviceModel> _devices = [];
    BluetoothDeviceModel? _connectedDevice;
    bool _isScanning = false;
    bool _isConnected = false;
    Map<String, List<double>> _liveEcgData = {};

    StreamSubscription? _scanSubscription;
    StreamSubscription? _connectionSubscription;
    StreamSubscription? _dataSubscription;

    // Getters
    List<BluetoothDeviceModel> get devices => _devices;
    BluetoothDeviceModel? get connectedDevice => _connectedDevice;
    bool get isScanning => _isScanning;
    bool get isConnected => _isConnected;
    Map<String, List<double>> get liveEcgData => _liveEcgData;

    // Methods
    void startScanning() {
      _isScanning = true;
      _devices.clear();
      notifyListeners();

      _scanSubscription = _scanDevicesUseCase.execute().listen(
        (devicesList) {
          _devices = devicesList;
          notifyListeners();
        },
        onError: (error) {
          _isScanning = false;
          notifyListeners();
        },
      );
    }

    void stopScanning() {
      _scanSubscription?.cancel();
      _isScanning = false;
      notifyListeners();
    }

    Future<void> connectToDevice(String deviceId) async {
      _connectionSubscription = _bluetoothRepository
          .connectToDevice(deviceId)
          .listen((isConnected) {
        _isConnected = isConnected;
        if (isConnected) {
          _connectedDevice = _devices.firstWhere((d) => d.id == deviceId);
          _startListeningToEcgData();
        }
        notifyListeners();
      });
    }

    void _startListeningToEcgData() {
      final characteristic = QualifiedCharacteristic(/* ... */);

      _dataSubscription = _bluetoothRepository
          .getEcgDataStream(characteristic)
          .listen((rawData) {
        _liveEcgData = _parseEcgDataUseCase.execute(rawData);
        notifyListeners();
      });
    }

    void disconnect() {
      _dataSubscription?.cancel();
      _connectionSubscription?.cancel();
      _isConnected = false;
      _connectedDevice = null;
      _liveEcgData.clear();
      notifyListeners();
    }

    @override
    void dispose() {
      _scanSubscription?.cancel();
      _connectionSubscription?.cancel();
      _dataSubscription?.cancel();
      super.dispose();
    }
  }

  Create presentation/viewmodels/ecg/ecg_viewmodel.dart:
  class EcgViewModel extends ChangeNotifier {
    final EcgRepository _ecgRepository;

    EcgViewModel(this._ecgRepository);

    // State
    List<EcgRecordModel> _records = [];
    Map<String, dynamic>? _selectedRecordData;
    bool _isLoading = false;
    String? _errorMessage;

    // Getters
    List<EcgRecordModel> get records => _records;
    Map<String, dynamic>? get selectedRecordData => _selectedRecordData;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    // Methods
    Future<void> loadRecords(String userId) async {
      _setLoading(true);

      try {
        _records = await _ecgRepository.getRecords(userId);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      } finally {
        _setLoading(false);
      }
    }

    Future<void> loadRecordData(String recordId) async {
      _setLoading(true);

      try {
        _selectedRecordData = await _ecgRepository.getRecordData(recordId);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      } finally {
        _setLoading(false);
      }
    }

    Future<File> saveRecordLocally(List<Map<String, dynamic>> data) async {
      return await _ecgRepository.saveRecordLocally(data: data);
    }

    Future<void> uploadRecord(File file, Map<String, dynamic> metadata) async {
      _setLoading(true);

      try {
        await _ecgRepository.uploadRecord(file, metadata);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      } finally {
        _setLoading(false);
      }
    }

    void _setLoading(bool value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  ---
  Phase 5: Presentation Layer - Views

  Step 12-14: Reorganize Screens and Widgets

  Reorganize screens:
  - screens/login_screen/log_in_screen.dart → presentation/screens/auth/login_screen.dart
  - screens/login_screen/sign_up_screen.dart → presentation/screens/auth/signup_screen.dart
  - screens/bluetooth_screens/ble_scanning_screen.dart → presentation/screens/bluetooth/ble_scanning_screen.dart
  - screens/bluetooth_screens/ble_live_chart.dart → presentation/screens/bluetooth/ble_live_chart_screen.dart
  - screens/history_screens/history_screen.dart → presentation/screens/measurement/history_screen.dart
  - screens/history_screens/history_record_chart.dart → presentation/screens/measurement/history_detail_screen.dart

  Move widgets:
  - components/ecg_chart_widget.dart → presentation/widgets/charts/ecg_chart_widget.dart
  - components/one_perfect_chart.dart → presentation/widgets/charts/one_perfect_chart.dart
  - components/submit_button.dart → presentation/widgets/common/submit_button.dart
  - components/circular_avatar.dart → presentation/widgets/common/circular_avatar.dart

  Update screen to use ViewModel:

  Example: presentation/screens/auth/login_screen.dart
  class LoginScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            if (authViewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return LoginForm(
              onLogin: (email, password) {
                authViewModel.login(email, password);
              },
              errorMessage: authViewModel.errorMessage,
            );
          },
        ),
      );
    }
  }

  ---
  Phase 6: Update Main Entry Point

  Step 15: Update main.dart

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Initialize services
    final storageService = StorageService();
    final dio = DioConfig.createDio();
    final ble = FlutterReactiveBle();

    // Initialize data sources
    final authApi = AuthApi(dio);
    final authLocalStorage = AuthLocalStorage(storageService);
    final bleDataSource = BleDataSource(ble);
    final ecgApi = EcgApi(dio);
    final ecgLocalStorage = EcgLocalStorage(FileManager(), CsvParser());

    // Initialize repositories
    final authRepository = AuthRepository(authApi, authLocalStorage);
    final bluetoothRepository = BluetoothRepository(bleDataSource);
    final ecgRepository = EcgRepository(ecgApi, ecgLocalStorage);

    // Initialize use cases
    final loginUseCase = LoginUseCase(authRepository);
    final scanDevicesUseCase = ScanDevicesUseCase(bluetoothRepository);
    final parseEcgDataUseCase = ParseEcgDataUseCase(EcgPacketParser());

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(loginUseCase, authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => BluetoothViewModel(
              scanDevicesUseCase,
              bluetoothRepository,
              parseEcgDataUseCase,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => EcgViewModel(ecgRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => UserViewModel(),
          ),
        ],
        child: FmECGApp(),
      ),
    );
  }

  ---
  Phase 7: Testing & Cleanup

  Step 16-18: Test Each Feature

  Auth flow:
  - Test login with valid/invalid credentials
  - Test token storage and retrieval
  - Test logout
  - Test auto-login on app restart

  Bluetooth measurement:
  - Test device scanning
  - Test device connection
  - Test live ECG data display
  - Test disconnect

  Measurement history:
  - Test loading records list
  - Test viewing record details
  - Test uploading records

  Step 19-20: Cleanup

  Remove old files:
  - Delete providers/ folder (replaced by presentation/viewmodels/)
  - Delete controllers/ folder (moved to domain/ or repositories)
  - Delete old constants/, utils/, networks/ folders

  Update imports:
  - Use find and replace to update all import paths
  - Run flutter pub run dependency_validator to check for unused dependencies

  ---
  Benefits of This Structure

  1. Separation of Concerns: Each layer has a single responsibility
  2. Testability: ViewModels and repositories can be easily unit tested
  3. Scalability: Easy to add new features without affecting existing code
  4. Maintainability: Clear structure makes code easier to understand
  5. Flexibility: Can swap implementations (e.g., change from SharedPreferences to Hive)

  ---
  Recommended Order of Implementation

  For minimal disruption, I recommend this order:

  1. Auth feature (most critical, affects everything)
  2. ECG measurement history (simpler, good practice)
  3. Bluetooth measurement (most complex, but by this point you'll have the pattern down)
