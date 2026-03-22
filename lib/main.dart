import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('id', null);
  await initializeDateFormatting('ja', null);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, 
      statusBarColor: Colors.transparent, 
      systemNavigationBarIconBrightness: Brightness.light, 
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('id'), Locale('ja')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: const EsutoruApp(),
    ),
  );
}

class EsutoruApp extends StatelessWidget {
  const EsutoruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esutoru',
      
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, 
        fontFamily: 'Roboto', 
      ),
      
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, 
    );
  }
}