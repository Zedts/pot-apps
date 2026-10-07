import 'package:flutter/foundation.dart';

/// Base ViewModel providing lifecycle awareness and memory-safe listener notification.
/// Prevents "A ChangeNotifier was used after being disposed" crashes when async operations
/// finish after the user has navigated away or closed a modal.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  /// Indicates whether this ViewModel instance has been disposed.
  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
