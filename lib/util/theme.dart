import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFFFFFF),
    colorScheme: ColorScheme.light(
      primary: Colors.pink,
      onSecondary: Colors.pink,
      secondary: Colors.pink,
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF000000)),
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000))),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardTheme: const CardTheme(
      color: Color(0xFFE9EBEA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFFFFFFF),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.pink,
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        focusColor:  Colors.pink,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.pink,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(10.0)),
        border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(10.0))),
    bottomAppBarColor: const Color(0xFFE0E0E0),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme:  IconThemeData(color: Colors.pink,),
      selectedLabelStyle: TextStyle(color: Colors.pink,),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: const Color(0xFFFFFFFF),
    ),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFFFFFFFF)));

ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF202126),
    scaffoldBackgroundColor: const Color(0xFF202126),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB87DBC),
      onSecondary: Color(0xFFB87DBC),
      secondary: Color(0xFFB87DBC),
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFF202126),
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF))),
    cardTheme: const CardTheme(
      color: Color(0xFF323036),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF303136),
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF303136),
        focusColor: const Color(0xFFB87DBC),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFB87DBC),
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[850]!,
            ),
            borderRadius: BorderRadius.circular(10.0)),
        border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[850]!,
            ),
            borderRadius: BorderRadius.circular(10.0))),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: Color(0xFFB87DBC)),
      selectedLabelStyle: TextStyle(color: Color(0xFFB87DBC)),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Color(0xFF202126),
    ),

    bottomAppBarColor: const Color(0xFF202126),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFF202126)));
