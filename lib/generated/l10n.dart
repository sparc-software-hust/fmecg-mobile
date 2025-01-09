// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to my app,`
  String get welcomeSentence {
    return Intl.message(
      'Welcome to my app,',
      name: 'welcomeSentence',
      desc: '',
      args: [],
    );
  }

  /// `Heartbeat`
  String get heartbeat {
    return Intl.message(
      'Heartbeat',
      name: 'heartbeat',
      desc: '',
      args: [],
    );
  }

  /// `Blood pressure`
  String get bloodPressure {
    return Intl.message(
      'Blood pressure',
      name: 'bloodPressure',
      desc: '',
      args: [],
    );
  }

  /// `Systolic`
  String get systolic {
    return Intl.message(
      'Systolic',
      name: 'systolic',
      desc: '',
      args: [],
    );
  }

  /// `diastolic`
  String get diastolic {
    return Intl.message(
      'diastolic',
      name: 'diastolic',
      desc: '',
      args: [],
    );
  }

  /// `Variability`
  String get variability {
    return Intl.message(
      'Variability',
      name: 'variability',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message(
      'Or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Extremely high`
  String get extremelyHigh {
    return Intl.message(
      'Extremely high',
      name: 'extremelyHigh',
      desc: '',
      args: [],
    );
  }

  /// `Hypertension`
  String get hypertension {
    return Intl.message(
      'Hypertension',
      name: 'hypertension',
      desc: '',
      args: [],
    );
  }

  /// `Level`
  String get level {
    return Intl.message(
      'Level',
      name: 'level',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get normal {
    return Intl.message(
      'Normal',
      name: 'normal',
      desc: '',
      args: [],
    );
  }

  /// `Family member phone number`
  String get familyMemberPhone {
    return Intl.message(
      'Family member phone number',
      name: 'familyMemberPhone',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter`
  String get enter {
    return Intl.message(
      'Enter',
      name: 'enter',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth is {action} now!`
  String bluetoothStatusDes(Object action) {
    return Intl.message(
      'Bluetooth is $action now!',
      name: 'bluetoothStatusDes',
      desc: '',
      args: [action],
    );
  }

  /// `Turn on`
  String get turnOn {
    return Intl.message(
      'Turn on',
      name: 'turnOn',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get find {
    return Intl.message(
      'Find',
      name: 'find',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message(
      'Stop',
      name: 'stop',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Available devices`
  String get availableDevices {
    return Intl.message(
      'Available devices',
      name: 'availableDevices',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get connect {
    return Intl.message(
      'Connect',
      name: 'connect',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get connected {
    return Intl.message(
      'Connected',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `Scanning devices`
  String get scanningDevices {
    return Intl.message(
      'Scanning devices',
      name: 'scanningDevices',
      desc: '',
      args: [],
    );
  }

  /// `All devices found!`
  String get devicesFoundDes {
    return Intl.message(
      'All devices found!',
      name: 'devicesFoundDes',
      desc: '',
      args: [],
    );
  }

  /// `Measure`
  String get measure {
    return Intl.message(
      'Measure',
      name: 'measure',
      desc: '',
      args: [],
    );
  }

  /// `Let's connect your phone to hardware using Bluetooth`
  String get scanningDes {
    return Intl.message(
      'Let\'s connect your phone to hardware using Bluetooth',
      name: 'scanningDes',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Measurement Page`
  String get measurementPage {
    return Intl.message(
      'Measurement Page',
      name: 'measurementPage',
      desc: '',
      args: [],
    );
  }

  /// `Your blood pressure chart`
  String get yourBloodPressureChart {
    return Intl.message(
      'Your blood pressure chart',
      name: 'yourBloodPressureChart',
      desc: '',
      args: [],
    );
  }

  /// `Save and calculate`
  String get saveAndCalculate {
    return Intl.message(
      'Save and calculate',
      name: 'saveAndCalculate',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Data is being processed by Python`
  String get dataProcessingDes {
    return Intl.message(
      'Data is being processed by Python',
      name: 'dataProcessingDes',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Save data to storage`
  String get saveDataToStorage {
    return Intl.message(
      'Save data to storage',
      name: 'saveDataToStorage',
      desc: '',
      args: [],
    );
  }

  /// `Data processed`
  String get dataProcessed {
    return Intl.message(
      'Data processed',
      name: 'dataProcessed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
