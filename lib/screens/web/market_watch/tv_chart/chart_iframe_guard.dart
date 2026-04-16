class ChartIframeGuard {
  ChartIframeGuard._();

  static int _lockCount = 0;

  static bool get isLocked => _lockCount > 0;

  static void acquire() {
    _lockCount++;
  }

  static void release() {
    if (_lockCount > 0) {
      _lockCount--;
    }
  }

  static void reset() {
    _lockCount = 0;
  }
}

