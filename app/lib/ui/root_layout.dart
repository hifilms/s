import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'widgets/mini_player.dart';

class RootLayout extends StatelessWidget {
  const RootLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = context.watch<AudioService>();
    final showPlayer = audioService.showPlayer;
    final isMinimized = audioService.isMinimized;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content (Home)
          // Adjust bottom padding if mini player is showing?
          // MiniPlayer height is 70.
          Positioned.fill(
             bottom: (showPlayer && isMinimized) ? 70 : 0,
             child: const HomeScreen(),
          ),

          // Player Layer
          if (showPlayer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isMinimized ? MediaQuery.of(context).size.height - 70 : 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: isMinimized 
                ? const MiniPlayer() 
                : const PlayerScreen(),
            ),
        ],
      ),
    );
  }
}
