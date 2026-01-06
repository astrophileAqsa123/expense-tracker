import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/security_screen.dart';

class AppLockAndPermissionsGate extends StatefulWidget {
  final Widget child;

  /// show lock immediately on start
  final bool lockOnStart;

  /// enable/disable lock feature
  final bool enabled;

  /// lock again after app paused for this long
  final Duration lockAfter;

  /// if provided, Cancel will navigate to this route (ex: "/settings")
  final String? cancelRouteName;

  const AppLockAndPermissionsGate({
    super.key,
    required this.child,
    this.lockOnStart = true,
    this.enabled = true,
    this.lockAfter = const Duration(seconds: 10),
    this.cancelRouteName,
  });

  // ============================
  // ✅ PIN STORAGE
  // ============================
  static const String _pinKey = 'app_lock_pin';

  static Future<String?> getSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    if (pin == null || pin.isEmpty) return null;
    return pin;
  }

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  // ============================
  // ✅ PERMISSIONS (STATIC)
  // ============================
  static Future<bool> requestCamera(BuildContext context) =>
      _request(context, Permission.camera, name: 'Camera');

  static Future<bool> requestMicrophone(BuildContext context) =>
      _request(context, Permission.microphone, name: 'Microphone');

  static Future<bool> requestNotifications(BuildContext context) =>
      _request(context, Permission.notification, name: 'Notifications');

  static Future<bool> requestPhotosOrStorage(BuildContext context) async {
    final okPhotos = await _request(context, Permission.photos, name: 'Photos');
    if (okPhotos) return true;
    return _request(context, Permission.storage, name: 'Storage');
  }

  static Future<bool> requestLocation(BuildContext context) =>
      _request(context, Permission.locationWhenInUse, name: 'Location');

  static Future<bool> _request(
    BuildContext context,
    Permission permission, {
    required String name,
  }) async {
    PermissionStatus status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, name);
      return false;
    }

    status = await permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, name);
      return false;
    }

    _showDeniedSnack(context, name);
    return false;
  }

  static void _showDeniedSnack(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name permission denied.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$name permission is permanently denied.\n\nOpen Settings and enable it to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  State<AppLockAndPermissionsGate> createState() =>
      _AppLockAndPermissionsGateState();
}

class _AppLockAndPermissionsGateState extends State<AppLockAndPermissionsGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _locked = true;
  bool _busy = false;
  bool _supportedBio = true;

  DateTime? _lastPausedAt;

  String? _savedPin;
  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLock();
  }

  Future<void> _initLock() async {
    _supportedBio = await _canAuthenticate();
    _savedPin = await AppLockAndPermissionsGate.getSavedPin();

    if (!mounted) return;

    // ✅ If lock disabled OR no PIN set and no biometrics => don't lock
    if (!widget.enabled) {
      setState(() => _locked = false);
      return;
    }

    // ✅ If user has set PIN OR device supports biometrics -> allow lock
    final hasPin = _savedPin != null && _savedPin!.isNotEmpty;
    final canLock = hasPin || _supportedBio;

    if (!canLock) {
      setState(() => _locked = false);
      return;
    }

    // ✅ Start locked or not
    if (widget.lockOnStart) {
      setState(() => _locked = true);
    } else {
      setState(() => _locked = false);
    }
  }

  Future<bool> _canAuthenticate() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool supported = await _auth.isDeviceSupported();
      return canCheck || supported;
    } catch (_) {
      return false;
    }
  }

  void _markPaused() {
    _lastPausedAt = DateTime.now();
  }

  bool _shouldLockOnResume() {
    if (!widget.enabled) return false;
    if (_lastPausedAt == null) return false;
    final diff = DateTime.now().difference(_lastPausedAt!);
    return diff >= widget.lockAfter;
  }

  // ============================
  // ✅ UNLOCK WITH PIN
  // ============================
  Future<void> _unlockWithPin() async {
    final entered = _pinCtrl.text.trim();

    final hasPin = _savedPin != null && _savedPin!.isNotEmpty;
    if (!hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No PIN set yet. Please set it from Settings."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (entered != _savedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect PIN"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _locked = false);
  }

  // ============================
  // ✅ UNLOCK WITH BIOMETRICS
  // ============================
  Future<void> _unlockWithBiometrics() async {
    if (_busy) return;
    setState(() => _busy = true);

    bool ok = false;
    try {
      ok = await _auth.authenticate(
        localizedReason: 'Authenticate to open the app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _locked = !ok;
    });
  }

  void _cancel() {
    if (widget.cancelRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.cancelRouteName!);
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _markPaused();
    }

    if (state == AppLifecycleState.resumed) {
      _savedPin = await AppLockAndPermissionsGate.getSavedPin();

      final hasPin = _savedPin != null && _savedPin!.isNotEmpty;
      final canLock = hasPin || _supportedBio;

      if (canLock && _shouldLockOnResume()) {
        if (mounted) setState(() => _locked = true);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_locked) return widget.child;

    final hasPin = _savedPin != null && _savedPin!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 64, color: Color(0xFF156064)),
                const SizedBox(height: 14),
                const Text(
                  'App Locked',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  hasPin
                      ? 'Unlock using PIN or biometrics.'
                      : 'No PIN set. Unlock using biometrics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 18),

                // ✅ PIN input shows only if PIN exists
                if (hasPin) ...[
                  TextField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: "Enter PIN",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _unlockWithPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF156064),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text("Unlock with PIN"),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Change PIN button


                ],

                // ✅ Biometrics button
                ElevatedButton.icon(
                  onPressed: _busy || !_supportedBio ? null : _unlockWithBiometrics,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(_busy ? "Unlocking..." : "Unlock with Biometrics"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF156064),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Show "Set PIN" button if no PIN exists
if (!hasPin) ...[
  ElevatedButton(
    onPressed: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SecurityAndPermissionsScreen(),
        ),
      );

      // Refresh PIN after coming back
      _savedPin = await AppLockAndPermissionsGate.getSavedPin();
      if (mounted) setState(() {});
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade800,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
    ),
    child: const Text("Set App PIN"),
  ),
  const SizedBox(height: 12),
],


                if (!hasPin)
  TextButton(
    onPressed: _cancel,
    child: const Text("Cancel"),
  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
