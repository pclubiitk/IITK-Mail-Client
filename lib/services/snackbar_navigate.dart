import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The method's functionality is to nav back and show snack bar with appropriate msg(contrary to it's name :P)
/// When showSnackBarAndNavigate is called, the current frame finishes rendering.
/// The addPostFrameCallback schedules the snackbar to be shown and then pops the current screen.
/// The current screen navigates back (pops) immediately after scheduling the snackbar, 
/// but because the snackbar was scheduled to be shown after the frame is rendered, 
/// it gets displayed even though the current screen is no longer visible.
/// 
class SnackbarHelper {
  static void showSnackBarAndNavigate({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
      Navigator.of(context).pop();
    });
  }
}
