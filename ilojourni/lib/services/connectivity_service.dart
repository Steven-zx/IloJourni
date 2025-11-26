import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._();
  ConnectivityService._();
  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  Future<void> initialize() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    
    // Consider online if any connection is available (wifi, mobile, ethernet)
    _isOnline = results.any((result) => 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );

    if (wasOnline != _isOnline) {
      // print(_isOnline ? '🟢 Online' : '🔴 Offline');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
