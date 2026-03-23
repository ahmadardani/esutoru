import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppsSettingsScreen extends StatefulWidget {
  const HomeAppsSettingsScreen({super.key});

  @override
  State<HomeAppsSettingsScreen> createState() => _HomeAppsSettingsScreenState();
}

class _HomeAppsSettingsScreenState extends State<HomeAppsSettingsScreen> {
  List<String> savedPackages = ['', '', '', '', ''];
  List<Application?> favoriteApps = List.filled(5, null);
  List<Application> allApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    final prefs = await SharedPreferences.getInstance();
    List<String> packages = prefs.getStringList('favorite_apps') ?? ['', '', '', '', ''];
    List<Application?> loadedFavorites = List.filled(5, null);

    for (int i = 0; i < 5; i++) {
      if (packages[i].isNotEmpty) {
        try {
          loadedFavorites[i] = apps.firstWhere((app) => app.packageName == packages[i]);
        } catch (e) {
          packages[i] = '';
        }
      }
    }

    setState(() {
      allApps = apps;
      savedPackages = packages;
      favoriteApps = loadedFavorites;
      isLoading = false;
    });
  }

  Future<void> _saveApp(int index, Application? app) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteApps[index] = app;
      savedPackages[index] = app?.packageName ?? '';
    });
    await prefs.setStringList('favorite_apps', savedPackages);
  }

  void _showAppSelector(int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: allApps.length,
            itemBuilder: (context, index) {
              final app = allApps[index];
              return ListTile(
                leading: app is ApplicationWithIcon
                    ? Image.memory(app.icon, width: 40, height: 40)
                    : const Icon(Icons.apps, color: Colors.white),
                title: Text(app.appName, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  _saveApp(slotIndex, app);
                  Navigator.pop(context);
                },
              );
            },
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
        title: Text('home_apps_settings'.tr(), style: const TextStyle(fontSize: 18)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) {
                final app = favoriteApps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    tileColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: app is ApplicationWithIcon
                        ? Image.memory(app.icon, width: 40, height: 40)
                        : const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.add, color: Colors.white)),
                    title: Text(
                      app?.appName ?? 'select_app'.tr(),
                      style: TextStyle(color: app != null ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Slot ${index + 1}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: app != null
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _saveApp(index, null), 
                          )
                        : null,
                    onTap: () => _showAppSelector(index),
                  ),
                );
              },
            ),
    );
  }
}