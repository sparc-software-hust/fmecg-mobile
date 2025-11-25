import 'package:fmecg_mobile/components/live_chart.dart';
import 'package:fmecg_mobile/components/live_chart_sample.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_bloc.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_event.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_state.dart';
import 'package:fmecg_mobile/screens/bluetooth_screens/ble_screen.dart';
import 'package:fmecg_mobile/screens/login_screen/log_in_screen.dart';
import 'package:fmecg_mobile/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainMenuScreen();
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ECG Monitor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.favorite, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'ECG Data Monitor',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 8),
                      Text('Choose your monitoring mode', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Demo mode option
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveChartSample()));
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => LiveLineChart(UniqueKey())));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 28),
                        const SizedBox(width: 12),
                        const Text('Demo Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                // Description for demo mode
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Test with simulated ECG data - Perfect for learning and demonstration purposes',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

                // BLE mode option
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BleReactiveScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth, size: 28),
                        const SizedBox(width: 12),
                        const Text('Bluetooth ECG Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                // Description for BLE mode
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    'Connect to real ECG devices via Bluetooth - Requires compatible ECG hardware',
                    style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Footer info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '💡 Tip: Start with Demo Mode to familiarize yourself with the interface',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlocNavigate extends StatefulWidget {
  const BlocNavigate({Key? key}) : super(key: key);

  @override
  State<BlocNavigate> createState() => _BlocNavigateState();
}

class _BlocNavigateState extends State<BlocNavigate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(CheckAutoLogin());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return const MainScreen();
        } else if (state is AuthenticationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
