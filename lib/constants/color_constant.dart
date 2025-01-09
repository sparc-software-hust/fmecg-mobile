import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color primary = const Color(0xFF3879E9);
  static Color secondary = const Color(0xFFEE9CDA);
  static Color tertiary = const Color(0xFF7BE5C5);
  static Color quaternary = const Color(0xFF222566);
  static Color quinary = const Color(0xFFF7F9FB);
  static Color description = const Color(0XFFEDEDED);

  static const Color surface = Color(0xFFFDF8F8);
  static const Color onSurface = Color(0xFF090909);
  static const Color surfaceVariant = Color(0xFFEBE2E2);
  static const Color onSurfaceVariant = Color(0xFF121111);
  static const Color surfaceContainer = Color(0xffF3EDF7);
  static const Color outline = Color(0xFF7C7C7C);
  static const Color outlineVariant = Color(0xFFC8C8C8);

  static Color black9007e = fromHex('#7e000000');
  static Color blueGray100 = fromHex('#cfcfcf');
  static Color gray500 = fromHex('#979797');
  static Color blueGray10066 = fromHex('#66d9d9d9');
  static Color blueGray10001 = fromHex('#d9d9d9');
  static Color gray900 = fromHex('#191919');
  static Color gray90001 = fromHex('#2c2929');
  static Color black9000f = fromHex('#0f000000');
  static Color gray80014 = fromHex('#14444444');
  static Color blueA200 = fromHex('#4285f4');
  static Color gray50 = fromHex('#fafbfd');
  static Color black900 = fromHex('#000000');
  static Color gray9007e = fromHex('#7e2c2929');
  static Color bluegray400 = fromHex('#888888');
  static Color gray50033 = fromHex('#33979797');
  static Color deepPurpleA200 = fromHex('#7041ee');
  static Color gray90063 = fromHex('#632c2929');
  static Color whiteA700 = fromHex('#ffffff');
  static Color black90016 = fromHex('#16000000');
  static Color teal = fromHex("#16697b");

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
