import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CommonDataViewmodel extends ChangeNotifier {
  double _size = 200;
  double get size => _size;

  Timer? _timer;
  bool _isAnimating = false;

  /// Starts continuous animation loop (pulse effect) — runs for 50 seconds max
  void startContinuousAnimation({
    double from = 200,
    double to = 400,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    if (_isAnimating) return; // prevent duplicate loops
    _isAnimating = true;

    // Automatically stop animation after 50 seconds
    Future.delayed(const Duration(seconds: 50), () {
      stopAnimation();
    });

    _animateLoop(from, to, duration);
  }

  /// Recursive helper that runs forward and backward animation
  void _animateLoop(double from, double to, Duration duration) {
    if (!_isAnimating) return;

    final totalMs = duration.inMilliseconds;
    final startTime = DateTime.now();
    bool forward = _size == from;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isAnimating) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      double t = (elapsed / totalMs).clamp(0.0, 1.0);
      double eased = Curves.easeInOut.transform(t);

      _size = forward
          ? from + (to - from) * eased
          : to - (to - from) * eased; // reverse motion
      notifyListeners();

      if (t >= 1.0) {
        timer.cancel();
        // Reverse direction and repeat loop
        _animateLoop(forward ? to : from, forward ? from : to, duration);
      }
    });
  }

  /// Stop the looping animation manually or after timeout
  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAnimation();
    super.dispose();
  }
}
