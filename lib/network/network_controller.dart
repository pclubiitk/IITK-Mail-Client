import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

/// This class uses [connectivity_plus] package to check the internet and responds with a snackbar.
/// The [_updateConnectionStatus] gets the [ConnectivityResult] from [onConnectivityChanged.listen] to check the connectivity.
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isSnackbarOpen = false.obs; // To manually track the Snackbar state.

  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      if (!_isSnackbarOpen.value) {
        _isSnackbarOpen.value = true; // Mark Snackbar as open.
        Get.rawSnackbar(
          messageText: const Text(
            'PLEASE CONNECT TO THE INTERNET',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          isDismissible: false,
          duration: const Duration(days: 1), // Keeps the Snackbar open until manually dismissed.
          backgroundColor: Colors.red[400]!,
          icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );
      }
    } else {
      if (_isSnackbarOpen.value) {
        Get.closeCurrentSnackbar(); // Close the Snackbar.
        _isSnackbarOpen.value = false; // Mark Snackbar as closed.
      }
    }
  }
}
