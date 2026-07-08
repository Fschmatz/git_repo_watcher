import 'package:flutter/material.dart';

class ToastUtils {
  ToastUtils._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {Duration duration = const Duration(seconds: 3), bool isError = false}) {
    scaffoldMessengerKey.currentState?.let((messenger) {
      final colorScheme = Theme.of(messenger.context).colorScheme;
      _display(messenger, colorScheme, message, duration: duration, isError: isError);
    });
  }

  static void _display(ScaffoldMessengerState messenger, ColorScheme colorScheme, String message,
      {Duration duration = const Duration(seconds: 3), bool isError = false}) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? colorScheme.errorContainer : colorScheme.inverseSurface,
          content: Text(message, style: TextStyle(color: isError ? colorScheme.onErrorContainer : colorScheme.onInverseSurface)),
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void showSuccess() {
    show(
      "Success!",
    );
  }

  static void showError() {
    show("Error!", isError: true);
  }

  static void showErrorMessage(String message) {
    show(message, isError: true);
  }
}

extension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
