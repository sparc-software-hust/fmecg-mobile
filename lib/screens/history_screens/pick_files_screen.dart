// import 'package:fmecg_mobile/screens/history_screens/chart_result_python_screen.dart';
// import 'package:fmecg_mobile/utils/utils.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class PickFiles extends StatefulWidget {
//   const PickFiles({super.key, required this.txtPath});
//   final String txtPath;

//   @override
//   State<PickFiles> createState() => _PickFilesState();
// }

// class _PickFilesState extends State<PickFiles> {
//   static const platform = MethodChannel("com.example.method_channel/java");
//   String? pythonModulePath;
//   String errorLog = "";

//   @override
//   void initState() {
//     super.initState();
//   }

//   void choosePythonModulePath() async {
//     final FilePickerResult? result = await FilePicker.platform.pickFiles();
//     final bool canAddPath = result != null &&
//         !result.paths.contains(null) &&
//         result.isSinglePick &&
//         result.files.first.extension == "py";
//     if (canAddPath) {
//       setState(() {
//         pythonModulePath = result.paths.first!;
//       });
//     }
//   }

//   void sendDataToNativePython() async {
//     final bool cannotSend = widget.txtPath == "";
//     if (cannotSend) return;

//     OverlayEntry overlayLoadingWidget = Utils.setOverlayLoadingWithHeavyTask();
//     try {
//       Overlay.of(context).insert(overlayLoadingWidget);
//       final Map pathContext = {
//         'python_path': pythonModulePath,
//         'txt_path': widget.txtPath
//       };
//       final Map? dataReceived = await platform.invokeMethod("transfer_context_to_python", pathContext);
//       if (dataReceived == null) {
//         overlayLoadingWidget.remove();
//         return Utils.showDialogWarningError(context, false, "Lỗi khi xử lý dữ liệu với Python");
//       }
//       overlayLoadingWidget.remove();
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => ChartsResultPythonScreen(data: dataReceived)));
//     } catch (e, t) {
//       overlayLoadingWidget.remove();
//       Utils.showDialogWarningError(context, false, "Lỗi khi xử lý dữ liệu với Python");
//       setState(() => errorLog = "$e $t");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
//       child: SingleChildScrollView(
//         child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text("Nếu người dùng không chọn python từ file, default python file sẽ được chọn tự động", textAlign: TextAlign.center),
//           const SizedBox(height: 10),
//           InkWell(
//             onTap: choosePythonModulePath,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(4),
//                 color: Colors.blue,
//               ),
//               child: const Text("Get Python file path"),
//             ),
//           ),
//           const SizedBox(height: 4),

//           Text("Python file path: ${pythonModulePath ?? "default"}"),
//           const SizedBox(height: 10),
//           Text("Txt file path: ${widget.txtPath}"),
//           const SizedBox( height: 20,),
//           InkWell(
//             onTap: sendDataToNativePython,
//             child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.blue,
//                 ),
//                 child: const Text("Send to Python Native")),
//           ),
//           const SizedBox( height: 20,),
//           if (errorLog.isNotEmpty)
//           Text("ERROR: $errorLog")
//         ],
//             ),
//       ),
//     );
//   }
// }
