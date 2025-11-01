import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;
  bool _initialized = false;
  StreamSubscription<ConnectivityResult>? _nativeSub;

  ConnectivityService();

  /// Call this after plugins are registered (after runApp / appRunner).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // initial check
    await _updateStatus();

    // subscribe to native connectivity changes
    _nativeSub = _connectivity.onConnectivityChanged.listen((_) {
      _updateStatus();
    });
  }

  Future<void> _updateStatus() async {
    final online = await _hasInternet();
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
    } else {
      // still update initial state for listeners even if unchanged
      if (!_controller.hasListener) return;
      _controller.add(_isOnline);
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onStatusChange => _controller.stream;
  bool get isOnline => _isOnline;

  void dispose() {
    _nativeSub?.cancel();
    _controller.close();
  }
}
