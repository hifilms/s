import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added
import '../../services/ad_manager.dart'; // Added
import '../../services/audio_service.dart'; // Added
import '../../models/video.dart';

class MoodsRow extends StatelessWidget {
  final List<HiVideo> moodVideos; // One representative video per category (4-13)

  const MoodsRow({super.key, required this.moodVideos});

  @override
  Widget build(BuildContext context) {
    if (moodVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Moods",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white70), // "See All text is hidden (only Arrow icon)"
            ],
          ),
        ),
        SizedBox(
          height: 100, // Slightly larger than video row? Or smaller? "Blurred thumbnails"
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: moodVideos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = moodVideos[index];
              return _buildMoodCard(context, video); // Passed context
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCard(BuildContext context, HiVideo video) {
    return GestureDetector(
      onTap: () {
         context.read<AdManager>().showAdIfAvailable(() {
            context.read<AudioService>().playVideo(video, contextPlaylist: moodVideos);
         });
      },
      child: SizedBox(
        width: 140,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              video.thumbnailMq,
              fit: BoxFit.cover,
            ),
            // Blur Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            // Category Name Center
            Center(
              child: Text(
                video.categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
