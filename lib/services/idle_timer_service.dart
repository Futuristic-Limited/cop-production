import 'dart:async';
import 'package:flutter/material.dart';

class IdleTimerService with WidgetsBindingObserver {
  final Duration timeoutDuration;
  final VoidCallback onTimeout;

  Timer? _timer;
  bool _isInBackground = false;

  IdleTimerService({required this.timeoutDuration, required this.onTimeout}) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(timeoutDuration, () {
      if (!_isInBackground) {
        onTimeout();
      }
    });
  }

  void resetTimer() {
    if (!_isInBackground) {
      _startTimer();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInBackground = state != AppLifecycleState.resumed;

    if (_isInBackground) {
      _timer?.cancel(); // stop timer in background
    } else {
      _startTimer(); // restart when app resumes
    }
  }
}
