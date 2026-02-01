import 'dart:math';

import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static BuildContext? _globalContext;
  static BuildContext? get globalContext => _globalContext;

  static setGlobalContext(context) {
    _globalContext = context;
  }

  static getRandomString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static getRandomNumber(length) {
    const _chars = '1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static int getCurrentTimestamp() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return timestamp;
  }

  static Future<bool> requestManageStorage() async {
    final PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<dynamic> showDialogWarningError(BuildContext context, bool isDark, String warningContent) {
    final Color colorInput = isDark ? const Color(0xFF25282A) : const Color(0xFFF2F4F7);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: colorInput,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Container(
                width: 230,
                height: 130,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      warningContent,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF6F6F7) : const Color(0xFF101828),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Color(0xff05AABD), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static OverlayEntry setOverlayLoadingWithHeavyTask() {
    return OverlayEntry(
      builder: (contextBuilder) {
        const bool isDark = false;
        const Color backgroundColorDialog = isDark ? Color(0xFF25282A) : Color(0xFFF2F4F7);
        const Color colorTitle = isDark ? Color(0xFFF6F6F7) : Color(0xFF101828);

        return Dialog(
          backgroundColor: backgroundColorDialog,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          child: SizedBox(
            width: 210,
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.current.dataProcessingDes,
                  style: const TextStyle(
                    color: colorTitle,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Color(0xff05AABD)),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showDialogLoginRequirement(context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Có lỗi xảy ra"),
          content: const Text("Bạn phải đăng nhập để thực hiện chức năng này!"),
          actions: [
            TextButton(
              child: const Text('Trở về'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
