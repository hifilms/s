import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/data_service.dart';
import 'services/ad_manager.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Mobile Ads
  MobileAds.instance.initialize();
  
  // Set system UI overlay style for premium feel
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize Storage Service
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataService()),
         ChangeNotifierProvider(create: (_) => AdManager()),
        ChangeNotifierProvider<StorageService>.value(value: storageService), // Changed to ChangeNotifierProvider
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: const HiMusicApp(),
    ),
  );
}

class HiMusicApp extends StatelessWidget {
  const HiMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hi MUSIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914), // Netflix-like Red or similar premium color
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Dark
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFFFFFFF),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
        fontFamily: 'Inter', 
      ),
      home: const SplashScreen(),
    );
  }
}
