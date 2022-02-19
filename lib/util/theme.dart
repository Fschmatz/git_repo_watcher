import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFFFDFF),
    colorScheme: const ColorScheme.light(
      primary: Colors.pink,
      onSecondary: Colors.pink,
      secondary: Colors.pink,
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFFFFFDFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF000000)),
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000))),
    scaffoldBackgroundColor: const Color(0xFFFFFDFF),
    cardTheme: const CardTheme(
      color: Color(0xFFF9F7FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFFFFDFF),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.pink,
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        focusColor:  Colors.pink,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme:  IconThemeData(color: Colors.pink,),
      selectedLabelStyle: TextStyle(color: Colors.pink,),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Color(0xFFFFFDFF),
    ),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFFFFFDFF)));

ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF222026),
    scaffoldBackgroundColor: const Color(0xFF222026),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFC695C9),
      onSecondary: Color(0xFFC695C9),
      secondary: Color(0xFFC695C9),
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFF222026),
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
        focusColor: const Color(0xFFC695C9),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFC695C9),
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
      selectedIconTheme: IconThemeData(color: Color(0xFFC695C9)),
      selectedLabelStyle: TextStyle(color: Color(0xFFC695C9)),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Color(0xFF222026),
    ),

    bottomAppBarColor: const Color(0xFF222026),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFF222026)));
