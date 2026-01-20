// Openapi Generator last run: : 2026-01-21T00:17:05.562361
import 'package:fmecg_mobile/app.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/providers/bluetooth_provider.dart';
import 'package:fmecg_mobile/providers/ecg_provider.dart';
import 'package:fmecg_mobile/providers/news_provider.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FmECGApp());
}

@Openapi(
  additionalProperties: DioProperties(pubName: 'fmecg_api', pubAuthor: 'sparc'),
  inputSpec: InputSpec(path: 'lib/openapi/api_spec.yaml'),
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/fmecg_api',
  debugLogging: true,
  skipSpecValidation: true,
)
class FmECGApp extends StatefulWidget {
  const FmECGApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FmECGAppState();
  }
}

class FmECGAppState extends State<FmECGApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => ECGProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          Utils.setGlobalContext(ctx);
          return MaterialApp(
            locale: const Locale('en'),
            debugShowCheckedModeBanner: false,
            home: const App(),
            theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('vi'),
            ],
          );
        },
      ),
    );
  }
}