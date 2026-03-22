import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_apps/device_apps.dart';
import 'settings_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<Application> allApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllApps();
  }

  Future<void> _loadAllApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    setState(() {
      allApps = apps;
      isLoading = false;
    });
  }

  void _showAppOptions(BuildContext context, Application app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  app.appName,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: Text('app_info'.tr(), style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  DeviceApps.openAppSettings(app.packageName); 
                },
              ),
              const SizedBox(height: 10), 
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('app_vault'.tr(), style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: allApps.length,
              itemBuilder: (context, index) {
                final app = allApps[index];
                return ListTile(
                  leading: app is ApplicationWithIcon
                      ? Image.memory(app.icon, width: 40, height: 40)
                      : const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.android, color: Colors.white)),
                  title: Text(app.appName, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    DeviceApps.openApp(app.packageName);
                  },
                  onLongPress: () {
                    _showAppOptions(context, app);
                  },
                );
              },
            ),
    );
  }
}