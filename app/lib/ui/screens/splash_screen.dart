import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/data_service.dart';
import '../../services/ad_manager.dart';
import '../../ui/root_layout.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final dataService = context.read<DataService>();
    final adManager = context.read<AdManager>();

    // Parallel fetch: Data + Ad Config
    // We don't await Ad Load for navigation, but we await Ad Config fetch if critical. 
    // Usually Ad load is background.
    
    // Fetch Ad Config (and then load ad in background)
    adManager.fetchAdConfig().then((_) {
       adManager.loadAd();
    });

    // Fetch Data
    await dataService.fetchData();

    if (!mounted) return;

    if (dataService.hasError && dataService.allVideos.isEmpty) {
       // Error state handled in build
    } else {
       // Success
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (_) => const RootLayout()),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: dataService.hasError && dataService.allVideos.isEmpty 
          ? _buildErrorState(dataService.errorMessage)
          : _buildLoadingState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App Icon (Placeholder)
        const Icon(Icons.music_note, size: 80, color: Colors.red)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5))
            .scaleXY(end: 1.1, duration: 800.ms)
            .then(delay: 800.ms)
            .scaleXY(end: 1.0, duration: 800.ms),
        const SizedBox(height: 20),
        const Text(
          "Hi MUSIC",
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.signal_wifi_off, size: 60, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          "No Internet",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            _initApp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text("Reload"),
        ),
      ],
    );
  }
}
