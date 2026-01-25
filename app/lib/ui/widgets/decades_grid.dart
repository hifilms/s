import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added
import '../../services/ad_manager.dart'; // Added
import '../../services/audio_service.dart'; // Added
import '../../models/video.dart';

class DecadesGrid extends StatelessWidget {
  final List<HiVideo> decadeVideos; // One representative video per decade category

  const DecadesGrid({super.key, required this.decadeVideos});

  @override
  Widget build(BuildContext context) {
    if (decadeVideos.isEmpty) return const SizedBox.shrink();

    // 2-Column Grid for Decades (8 categories)
    // "2-Column Grid (8 categories). Blurred thumbnails + Year Name centered. Vertical divider between cards."
    // Vertical divider between cards implies a visible separator? Or just spacing?
    // "Vertical divider between cards" -> Usually means a line. 
    // GridView doesn't easily support dividers between items individually, providing a border is easier.

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Decades",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: decadeVideos.length,
            itemBuilder: (context, index) {
              final video = decadeVideos[index];
              return _buildDecadeCard(context, video);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDecadeCard(BuildContext context, HiVideo video) {
    return GestureDetector(
      onTap: () {
         context.read<AdManager>().showAdIfAvailable(() {
             context.read<AudioService>().playVideo(video, contextPlaylist: decadeVideos);
         });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
             Image.network(
                video.thumbnailMq,
                fit: BoxFit.cover,
             ),
             BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.3)),
             ),
             Center(
               child: Text(
                 video.categoryName, // "Year Name centered" -> categoryName (e.g. "2000s")
                 style: const TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontSize: 16,
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
