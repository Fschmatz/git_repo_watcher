import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF0F2F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B591),
      onSecondary: Color(0xFF00A6B5),
      secondary: Color(0xFF09B091),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE0E2E5)),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Color(0xFFF0F2F5),
      color: Color(0xFFF0F2F5),
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    cardTheme: const CardTheme(
        color: Color(0xFFFCFEFF), surfaceTintColor: Color(0xFFFCFEFF)),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFF0F2F5),
      surfaceTintColor: Color(0xFFF0F2F5),
    ),
    inputDecorationTheme: const InputDecorationTheme(
        focusColor: Color(0xFF00B591),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF00B591),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF99A39F),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF99A39F),
          ),
        )),
    bottomAppBarColor: const Color(0xFFE0E0E0),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFF0F2F5),
    ),
    bottomSheetTheme:
        const BottomSheetThemeData(modalBackgroundColor: Color(0xFFF0F2F5),
            surfaceTintColor:  Color(0xFFF0F2F5)));

ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1C2127),
    scaffoldBackgroundColor: const Color(0xFF1C2127),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF73E3A6),
      onSecondary: Color(0xFF22B0D4),
      secondary: Color(0xFF60B286),
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Color(0xFF1C2127),
      color: Color(0xFF1C2127),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF1C2127),
      surfaceTintColor: Color(0xFF1C2127),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1C2127),
      surfaceTintColor: Color(0xFF1C2127),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF283B42)),
    inputDecorationTheme: const InputDecorationTheme(
        focusColor: Color(0xFF73E3A6),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF73E3A6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF79837F),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF79837F),
          ),
        )),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C2127),
    ),
    bottomAppBarColor: const Color(0xFF1C2127),
    bottomSheetTheme:
        const BottomSheetThemeData(
            modalBackgroundColor: Color(0xFF1C2127),
        surfaceTintColor:  Color(0xFF1C2127)));
