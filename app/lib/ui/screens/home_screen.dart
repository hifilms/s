import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../widgets/hero_slider.dart';
import 'home_list_rows.dart'; // Will create this next

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // For sticky effect if using slivers
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          // Sticky Top Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.black.withOpacity(0.9), // Semi-transparent or solid
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Row(
              children: [
                // Logo/Name
                const Icon(Icons.music_note, color: Colors.red), // Placeholder for Logo
                const SizedBox(width: 8),
                const Text("Hi MUSIC", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const MenuBottomSheet(),
                  );
                },
              ),
            ],
          ),
          
          // Hero Slider
          const SliverToBoxAdapter(
            child: HeroSlider(),
          ),

          // Content Rows
          const HomeListRows(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
      // User requested "Menu (Bottom Sheet)".
      // I will implement this as a function calling showModalBottomSheet in the actions, 
      // but if I use a Drawer widget it slides from side. 
      // The user specially said "Menu (Bottom Sheet)". 
      // So I should probably change the action to open a bottom sheet.
      return const SizedBox.shrink(); 
  }
}
