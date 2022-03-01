import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFCFDFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B5AD),
      onSecondary: Color(0xFF00A6B5),
      secondary: Color(0xFF00B5AD),
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFFFCFDFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF000000)),
        titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000))),
    scaffoldBackgroundColor: const Color(0xFFFCFDFF),
    cardTheme: const CardTheme(
      color: Color(0xFFFCFDFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFFCFDFF),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B5AD),
    ),
    inputDecorationTheme: InputDecorationTheme(
        focusColor:  const Color(0xFF00B5AD),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF00B5AD),
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
      selectedIconTheme:  IconThemeData(color: Color(0xFF00B5AD),),
      selectedLabelStyle: TextStyle(color: Color(0xFF00B5AD),),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Color(0xFFFCFDFF),
    ),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFFFCFDFF)));

ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1C2127),
    scaffoldBackgroundColor: const Color(0xFF1C2127),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF85F1D8),
      onSecondary: Color(0xFF22B0D4),
      secondary: Color(0xFF85F1D8),
    ),
    appBarTheme: const AppBarTheme(
        color: Color(0xFF1C2127),
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF))),
    cardTheme: const CardTheme(
      color: Color(0xFF1C2127),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1C2127),
    ),
    inputDecorationTheme: InputDecorationTheme(
        focusColor: const Color(0xFF85F1D8),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF85F1D8),
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
      selectedIconTheme: IconThemeData(color: Color(0xFF85F1D8)),
      selectedLabelStyle: TextStyle(color: Color(0xFF85F1D8)),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Color(0xFF1C2127),
    ),

    bottomAppBarColor: const Color(0xFF1C2127),
    bottomSheetTheme:
    const BottomSheetThemeData(modalBackgroundColor: Color(0xFF1C2127)));
