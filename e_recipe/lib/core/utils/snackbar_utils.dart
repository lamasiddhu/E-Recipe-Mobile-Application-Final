import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    showSnackbar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  static void showSuccessSnackbar(BuildContext context, String message) {
    showSnackbar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }
}
