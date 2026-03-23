import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_apps_settings_screen.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context) {
    String newPin = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('change_pin'.tr(), style: const TextStyle(color: Colors.white)),
          content: TextField(
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'enter_new_pin'.tr(),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 0),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
            onChanged: (val) => newPin = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (newPin.length == 4) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('vault_pin', newPin);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('pin_changed'.tr()), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('pin_length_error'.tr()), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('settings'.tr(), style: const TextStyle(fontSize: 18)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.white),
            title: Text('change_pin'.tr(), style: const TextStyle(color: Colors.white)),
            onTap: () => _showChangePinDialog(context),
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.apps, color: Colors.white),
            title: Text('home_apps_settings'.tr(), style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeAppsSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}