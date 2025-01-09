import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:flutter/material.dart';

class ThemeECG {
  static ThemeData lightTheme = ThemeData(
    primaryColor: ColorConstant.primary,
    scaffoldBackgroundColor: ColorConstant.quinary,
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.red,
    ),
    iconTheme: const IconThemeData(
      color: Colors.red,
    ),
    colorScheme: const ColorScheme.light(
    ),
    // appBarTheme: AppBarTheme(
    //   backgroundColor: ColorConstant.primary,
    //   elevation: 1
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey[600];
            } else {
              return ColorConstant.primary;
            }
          },
        ),
        
      )
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstant.primary
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: ColorConstant.primary,
      unselectedItemColor: ColorConstant.quaternary
    ),
    fontFamily: "Roboto"
  );

  static ThemeData darkTheme = ThemeData(
    // brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstant.quaternary,
    primaryColor: ColorConstant.quaternary,
    colorScheme: ColorScheme.dark(
      primary: ColorConstant.quaternary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: ColorConstant.primary,
      unselectedItemColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.red
    ),
    fontFamily: "Roboto"
  );
}