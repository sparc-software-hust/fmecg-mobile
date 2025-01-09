import 'package:connectivity_plus/connectivity_plus.dart';

abstract class InternetEvent {}

class CheckInternetConnection extends InternetEvent {}
class SetInternetConnection extends InternetEvent {
  final ConnectivityResult type;

  SetInternetConnection({required this.type});
}
