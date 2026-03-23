import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFavoriteApps();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _loadFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedPackages = prefs.getStringList('favorite_apps') ?? ['', '', '', '', ''];
    List<Application?> loadedApps = List.filled(5, null);

    for (int i = 0; i < 5; i++) {
      if (savedPackages[i].isNotEmpty) {
        try {
          loadedApps[i] = await DeviceApps.getApp(savedPackages[i], true);
        } catch (e) {
          
        }
      }
    }

    if (mounted) {
      setState(() {
        favoriteApps = loadedApps;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildAppButton(Application app) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          DeviceApps.openApp(app.packageName);
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
              app.appName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String langCode = context.locale.languageCode;
    String formattedTime = DateFormat('HH:mm').format(_currentTime);
    String formattedDate = DateFormat('EEEE, d MMMM yyyy', langCode).format(_currentTime);

    final validApps = favoriteApps.whereType<Application>().toList();
    final emptyCount = 5 - validApps.length;

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

            SizedBox(
              height: 350, 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: validApps.isEmpty
                    ? Center(
                        child: Text(
                          'no_apps_yet'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...validApps.map((app) => _buildAppButton(app)),
                          
                          if (emptyCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'empty_slots'.tr(args: [emptyCount.toString()]),
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            const Spacer(),

            IconButton(
              icon: const Icon(Icons.lock_outline, color: Colors.grey, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinScreen(
                      onReturn: () {
                        if (mounted) _loadFavoriteApps();
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}