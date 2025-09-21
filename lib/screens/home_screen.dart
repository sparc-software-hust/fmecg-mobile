import 'dart:io';

import 'package:fmecg_mobile/components/circular_avatar.dart';
import 'package:fmecg_mobile/components/live_chart.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/screens/bluetooth_screens/ble_screen.dart';
import 'package:fmecg_mobile/screens/preview_calculation.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  late File fileToSave;
  bool isShowChart = false;

  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;
  final FocusNode focusInputPhone = FocusNode();
  String phoneNumberWarning = "";

  Map allNews = {};
  @override
  void initState() {
    super.initState();
    _getInitPhoneNumber();
    // getDoctorAssigned();
    // NewsController.getAllNews();
  }

  // void getDoctorAssigned() async {
  //   int patientId = await Utils.getUserId();
  //   UserController.getDoctorAssigned(patientId);
  // }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
    focusInputPhone.dispose();
  }

  _savePhoneNumberToSharedPrefs(String phoneNumber) async {
    const String keyToSave = "phone_number_warning";
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(keyToSave, phoneNumber);
  }

  _getInitPhoneNumber() async {
    const String keyInit = "phone_number_warning";
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final bool isExistPhoneNumber = preferences.containsKey(keyInit);
    if (isExistPhoneNumber) {
      _phoneController.text = preferences.getString(keyInit)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    //final accessToken = Provider.of<AuthProvider>(context, listen: false).token;
    //print("home$accessToken: ");

    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 10),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // header
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row(children: [
                  //   const SizedBox(width: 8),
                  //   Column(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text("Chào mừng đến với fmECG"),
                  //       Text(
                  //         "Thai Dong",
                  //         style: TextStyle(
                  //           color: ColorConstant.primary,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ]),
                  const IconButton(icon: Icon(Icons.menu, size: 35), onPressed: null),
                  Row(
                    children: [
                      // const DarkLightSwitch(),
                      InkWell(child: Icon(PhosphorIcons.regular.bell)),
                      SizedBox(width: width * 0.05),
                      const CircularAvatar(imageAsset: 'assets/images/doctor.png', radius: 27),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${S.current.welcomeSentence}\nFinnick",
                      style: TextStyle(color: ColorConstant.black900, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      NumberCard(
                        leadingIcon: Icon(PhosphorIcons.fill.heartbeat, color: Colors.red.shade400),
                        centerImage: Image.asset("assets/images/heart_rate.png"),
                        number: 82.0,
                        text: S.current.heartbeat,
                        subText: "",
                        unit: "bpm",
                        // color1: Colors.grey,
                        // color2: Colors.grey,
                      ),
                      NumberCard(
                        leadingIcon: Icon(PhosphorIcons.fill.stethoscope),
                        centerImage: Image.asset("assets/images/blood_pressure.png"),
                        number: 72.9,
                        text: S.current.bloodPressure,
                        subText: "",
                        unit: "mmHg",
                        // color1: Colors.grey,
                        // color2: Colors.grey,
                      ),
                      // NumberCard(
                      //   leadingIcon: Icon(PhosphorIcons.fill.heartbeat,
                      //       color: Colors.red.shade400),
                      //   number: 82.6,
                      //   centerImage:
                      //       Image.asset("assets/images/heart_rate.png"),
                      //   text: "Nhịp tim ",
                      //   subText: "Thai nhi",
                      //   unit: "bpm",
                      //   // color1: ColorConstant.primary,
                      //   // color1: Colors.grey,
                      //   // color2: Colors.grey,
                      //   //  color2: ColorConstant.primary,
                      // ),
                      // NumberCard(
                      //   centerImage:
                      //       Image.asset("assets/images/blood_pressure.png"),
                      //   leadingIcon: Icon(PhosphorIcons.fill.stethoscope),
                      //   number: 86.0,
                      //   text: "Huyết áp",
                      //   subText: "Thai nhi",
                      //   unit: "mmHg",
                      //   //color1: ColorConstant.primary,
                      //   // color1: ColorConstant.teal,
                      //   // color2: ColorConstant.teal,
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            !isShowChart
                ? ImageCard(
                  imageAsset: 'assets/images/heart_rate_example.jpeg',
                  functionScanBluetooth: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BleReactiveScreen()));
                  },
                  temporaryNothing: () async {
                    FilesManagement.createDirectoryFirstTimeWithDevice();
                    fileToSave = await FilesManagement.setUpFileToSaveDataMeasurement();
                    setState(() {
                      isShowChart = true;
                    });
                  },
                )
                : LiveChartSample(fileToSave: fileToSave, callBackToPreview: () => setState(() => isShowChart = false)),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                S.current.familyMemberPhone,
                style: TextStyle(color: ColorConstant.quaternary, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),

            // Ô nhập liệu số điện thoại
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: _isEditing,
              focusNode: focusInputPhone,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "${S.current.enter} ${S.current.phoneNumber.toLowerCase()}",
                labelText: S.current.phoneNumber,
              ),
              onChanged:
                  (text) => setState(() {
                    phoneNumberWarning = _phoneController.text;
                  }),
            ),

            // Nút chỉnh sửa và lưu
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các nút
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                    focusInputPhone.requestFocus();
                  },
                  child: Text(S.current.edit),
                ),
                const SizedBox(width: 20), // Khoảng cách giữa các nút
                ElevatedButton(
                  onPressed:
                      phoneNumberWarning == ""
                          ? null
                          : () async {
                            await _savePhoneNumberToSharedPrefs(_phoneController.text);
                            setState(() {
                              _isEditing = false;
                              phoneNumberWarning = "";
                            });
                          },
                  child: Text(S.current.save),
                ),
              ],
            ),
          ],
        ),
        // child: LiveChartSample()
      ),
    );
  }
}

class DarkLightSwitch extends StatefulWidget {
  const DarkLightSwitch({Key? key}) : super(key: key);

  @override
  State<DarkLightSwitch> createState() => _DarkLightSwitchState();
}

class _DarkLightSwitchState extends State<DarkLightSwitch> {
  bool isDarkSwitch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: 60,
      height: 35.0,
      toggleSize: 25.0,
      value: isDarkSwitch,
      borderRadius: 20.0,
      padding: 1.5,
      activeToggleColor: const Color(0xFF6E40C9),
      inactiveToggleColor: const Color(0xFF2F363D),
      activeSwitchBorder: Border.all(color: const Color(0xFF3C1E70), width: 3.0),
      inactiveSwitchBorder: Border.all(color: const Color(0xFFD1D5DA), width: 3.0),
      activeColor: const Color(0xFF271052),
      inactiveColor: Colors.white,
      activeIcon: const Icon(Icons.nightlight_round, color: Color(0xFFF8E3A1)),
      inactiveIcon: const Icon(Icons.wb_sunny, color: Color(0xFFFFDF5D)),
      onToggle: (val) {
        Provider.of<AuthProvider>(context, listen: false).isAutoTheme = false;
        final auth = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          isDarkSwitch = val;
        });
        if (isDarkSwitch) {
          auth.setTheme(ThemeType.dark, false);
        } else {
          auth.setTheme(ThemeType.light, false);
        }
      },
    );
  }
}

class SquareContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function? onTap;

  const SquareContainer({Key? key, required this.icon, required this.text, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(color: ColorConstant.description, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ColorConstant.quaternary, size: 35.0),
              const SizedBox(height: 10.0),
              Text(
                text,
                style: TextStyle(color: ColorConstant.quaternary, fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberCard extends StatefulWidget {
  final double number;
  final String text;
  final String subText;
  final String unit;
  final Icon leadingIcon;
  final Image centerImage;
  final Function? onTap;

  const NumberCard({
    Key? key,
    required this.number,
    required this.text,
    required this.subText,
    required this.unit,
    required this.centerImage,
    required this.leadingIcon,
    this.onTap,
  }) : super(key: key);

  @override
  State<NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<NumberCard> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isClicked = !_isClicked;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PreviewCalculation()));
        widget.onTap?.call();
      },
      child: Container(
        width: width * 0.4,
        height: height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: _isClicked ? [Colors.teal, Colors.tealAccent] : [Colors.grey, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 2, child: widget.leadingIcon),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isClicked ? ColorConstant.black900 : ColorConstant.description,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3.0),
            Text(widget.subText, style: TextStyle(fontSize: 16.0, color: _isClicked ? Colors.amber : Colors.brown)),
            const SizedBox(height: 10.0),
            Expanded(child: widget.centerImage),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${widget.number}',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: _isClicked ? ColorConstant.black900 : ColorConstant.description,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.unit,
                  style: TextStyle(
                    color: _isClicked ? ColorConstant.black900 : ColorConstant.description,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final String imageAsset;
  final Function() functionScanBluetooth;
  final Function() temporaryNothing;

  const ImageCard({
    Key? key,
    required this.imageAsset,
    required this.functionScanBluetooth,
    required this.temporaryNothing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstant.quinary,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(imageAsset, width: double.infinity, height: 200.0, fit: BoxFit.cover),
          ),
          // const SizedBox(height: 12.0),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: functionScanBluetooth, child: const Text("Scan bluetooth")),
              ElevatedButton(onPressed: temporaryNothing, child: const Text("Test live chart")),
            ],
          ),
        ],
      ),
    );
  }
}
