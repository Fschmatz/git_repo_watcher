import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'app_theme.dart';
import 'service/background_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundService.taskName) {
      await BackgroundService.runRefreshTask();
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher);

  runApp(
    EasyDynamicThemeWidget(
      child: const AppTheme(),
    ),
  );
}
