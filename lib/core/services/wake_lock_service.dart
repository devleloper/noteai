import 'package:wakelock_plus/wakelock_plus.dart';

/// Service for managing screen wake lock to prevent screen from turning off
/// during recording sessions.
class WakeLockService {
  static final WakeLockService _instance = WakeLockService._internal();
  factory WakeLockService() => _instance;
  WakeLockService._internal();

  bool _isWakeLockEnabled = false;

  /// Check if wake lock is currently enabled
  bool get isWakeLockEnabled => _isWakeLockEnabled;

  /// Enable wake lock to keep screen on
  /// Returns true if successful, false otherwise
  Future<bool> enableWakeLock() async {
    try {
      if (_isWakeLockEnabled) {
        print('WakeLockService: Wake lock already enabled');
        return true;
      }

      await WakelockPlus.enable();
      _isWakeLockEnabled = true;
      print('WakeLockService: Wake lock enabled successfully');
      return true;
    } catch (e) {
      print('WakeLockService: Failed to enable wake lock: $e');
      return false;
    }
  }

  /// Disable wake lock to allow screen to turn off
  /// Returns true if successful, false otherwise
  Future<bool> disableWakeLock() async {
    try {
      if (!_isWakeLockEnabled) {
        print('WakeLockService: Wake lock already disabled');
        return true;
      }

      await WakelockPlus.disable();
      _isWakeLockEnabled = false;
      print('WakeLockService: Wake lock disabled successfully');
      return true;
    } catch (e) {
      print('WakeLockService: Failed to disable wake lock: $e');
      return false;
    }
  }

  /// Toggle wake lock state
  /// Returns true if wake lock is enabled after toggle, false otherwise
  Future<bool> toggleWakeLock() async {
    if (_isWakeLockEnabled) {
      return !(await disableWakeLock());
    } else {
      return await enableWakeLock();
    }
  }

  /// Force disable wake lock (for cleanup scenarios)
  /// This method will disable wake lock even if there are errors
  Future<void> forceDisableWakeLock() async {
    try {
      await WakelockPlus.disable();
      _isWakeLockEnabled = false;
      print('WakeLockService: Wake lock force disabled');
    } catch (e) {
      print('WakeLockService: Error during force disable: $e');
      _isWakeLockEnabled = false; // Reset state even if API call failed
    }
  }

  /// Check if wake lock is supported on current platform
  Future<bool> isWakeLockSupported() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      print('WakeLockService: Error checking wake lock support: $e');
      return false;
    }
  }

  /// Get current wake lock status from the platform
  Future<bool> getCurrentWakeLockStatus() async {
    try {
      final status = await WakelockPlus.enabled;
      _isWakeLockEnabled = status;
      return status;
    } catch (e) {
      print('WakeLockService: Error getting wake lock status: $e');
      return _isWakeLockEnabled;
    }
  }
}
