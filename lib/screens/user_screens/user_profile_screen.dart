import 'package:fmecg_mobile/features/authentication/bloc/authentication_bloc.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_event.dart';
import 'package:fmecg_mobile/models/user_model.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Thai Dong');
    _emailController = TextEditingController(text: 'thai.dong@gmail.com');
    _bioController = TextEditingController(text: 'fmECG is my life');
    _locationController = TextEditingController(text: 'Hanoi');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // Khoảng cách giữa các ListTile
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10), // Viền xám cho mỗi ListTile
        borderRadius: BorderRadius.circular(10), // Góc bo tròn
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        leading: Icon(icon, color: iconColor),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final User? user = Provider.of<UserProvider>(context, listen: true).user;
    // if (user == null) return const SizedBox();
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: ColorConstant.primary, // Màu sắc của AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/doctor.png'),
                backgroundColor: Colors.transparent, // Set the background color to transparent
              ),
              const SizedBox(height: 5),
              Text("Thai Dongg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text(
                'Hà Nội, Việt Nam',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const <Widget>[
                    InfoCard(title: 'Age', value: '30', unit: 'years'),
                    InfoCard(title: 'Weight', value: '90', unit: 'kg'),
                    InfoCard(title: 'Height', value: '190', unit: 'cm'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildListTile(title: 'Personal Info', icon: Icons.person, iconColor: Colors.blue, onTap: () {}),
              _buildListTile(
                title: 'My Appointments',
                icon: Icons.calendar_today,
                iconColor: Colors.orange,
                onTap: () {},
              ),
              _buildListTile(title: 'My Doctors', icon: Icons.local_hospital, iconColor: Colors.red, onTap: () {}),
              _buildListTile(title: 'EHR Files', icon: Icons.folder, iconColor: Colors.green, onTap: () {}),
              _buildListTile(
                title: 'Wallet',
                icon: Icons.account_balance_wallet,
                iconColor: Colors.purple,
                onTap: () {},
              ),
              _buildListTile(
                title: 'Log out',
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutRequest());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom InfoCard widget with Title
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const InfoCard({Key? key, required this.title, required this.value, required this.unit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.normal)),
            const SizedBox(height: 4),
            Text(
              '$value $unit',
              style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
