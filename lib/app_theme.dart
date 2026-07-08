import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_repo_watcher/pages/home.dart';
import 'package:git_repo_watcher/util/toast_utils.dart';

class AppTheme extends StatefulWidget {
  const AppTheme({super.key});

  @override
  State<AppTheme> createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final darkScheme = darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

        ThemeData buildTheme(ColorScheme colorScheme) {
          return ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,           
            cardTheme: CardThemeData(
              color: colorScheme.surfaceContainerHigh,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            dividerTheme: DividerThemeData(color: colorScheme.surfaceContainerLow, space: 1),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            bottomSheetTheme: BottomSheetThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),             
            ),
            popupMenuTheme: PopupMenuThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: ToastUtils.scaffoldMessengerKey,
          theme: buildTheme(lightScheme),
          darkTheme: buildTheme(darkScheme),
          themeMode: EasyDynamicTheme.of(context).themeMode,
          home: const Home(),
        );
      },
    );
  }
}
