import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:async';
import 'pin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  
  List<Application?> favoriteApps = List.filled(5, null);
  List<Application> allApps = [];
  bool isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _loadApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    setState(() {
      allApps = apps;
      isLoadingApps = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showAppSelector(int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        if (isLoadingApps) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        
        return ListView.builder(
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
                setState(() {
                  favoriteApps[slotIndex] = app;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String langCode = context.locale.languageCode;
    String formattedTime = DateFormat('HH:mm').format(_currentTime);
    String formattedDate = DateFormat('EEEE, d MMMM yyyy', langCode).format(_currentTime);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            Text(formattedTime, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(formattedDate, style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const Spacer(flex: 2),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: List.generate(5, (index) {
                  final app = favoriteApps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (app == null) {
                          _showAppSelector(index);
                        } else {
                          DeviceApps.openApp(app.packageName);
                        }
                      },
                      onLongPress: () {
                        if (app != null) setState(() => favoriteApps[index] = null);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            app?.appName ?? 'add_app'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: app != null ? Colors.white : Colors.grey,
                              fontWeight: app != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            IconButton(
              icon: const Icon(Icons.lock_outline, color: Colors.grey, size: 30),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen())),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}