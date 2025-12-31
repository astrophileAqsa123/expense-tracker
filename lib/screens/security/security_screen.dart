import 'package:expense_tracker/screens/setting/app_lock_and_permissions.dart';
import 'package:flutter/material.dart';
class SecurityAndPermissionsScreen extends StatefulWidget {
  const SecurityAndPermissionsScreen({super.key});

  @override
  State<SecurityAndPermissionsScreen> createState() =>
      _SecurityAndPermissionsScreenState();
}

class _SecurityAndPermissionsScreenState extends State<SecurityAndPermissionsScreen> {
  final TextEditingController pin1 = TextEditingController();
  final TextEditingController pin2 = TextEditingController();

  @override
  void dispose() {
    pin1.dispose();
    pin2.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final p1 = pin1.text.trim();
    final p2 = pin2.text.trim();

    if (!RegExp(r'^\d{4,6}$').hasMatch(p1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN must be 4-6 digits"), backgroundColor: Colors.red),
      );
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PINs do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    await AppLockAndPermissionsGate.savePin(p1);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PIN saved successfully"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Security & Permissions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Create / Change App PIN",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: pin1,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: "New PIN (4-6 digits)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pin2,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: "Confirm PIN",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _savePin,
            child: const Text("Save PIN"),
          ),
          const SizedBox(height: 20),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Request Camera Permission"),
            onTap: () => AppLockAndPermissionsGate.requestCamera(context),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text("Request Microphone Permission"),
            onTap: () => AppLockAndPermissionsGate.requestMicrophone(context),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Request Photos/Storage Permission"),
            onTap: () => AppLockAndPermissionsGate.requestPhotosOrStorage(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Request Notifications Permission"),
            onTap: () => AppLockAndPermissionsGate.requestNotifications(context),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Request Location Permission"),
            onTap: () => AppLockAndPermissionsGate.requestLocation(context),
          ),
        ],
      ),
    );
  }
}
