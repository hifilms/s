import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../services/ad_manager.dart';
import '../../services/audio_service.dart';
import '../../models/video.dart';

class HorizontalVideoList extends StatelessWidget {
  final String title;
  final List<HiVideo> videos;
  final VoidCallback? onSeeAll; // Hidden for Moods

  const HorizontalVideoList({
    super.key,
    required this.title,
    required this.videos,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text("See All", style: TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
        SizedBox(
          height: 140, // Adjust height as needed
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length > 10 ? 10 : videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildVideoCard(video, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(HiVideo video, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ad Logic -> Play
        context.read<AdManager>().showAdIfAvailable(() {
           // Play Video
           // Access AudioService via context (needs read, but we are in a build method here or use context.read)
           // "Dynamic Playlist" - Create a playlist context from the list?
           // I'll filter 'videos' to only passed list.
           context.read<AudioService>().playVideo(video, contextPlaylist: videos);
        });
      },
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailMq, // "mqdefault" requested for Hero, logic implies similar or default for others. "Original small thumbnails" -> default.jpg or mqdefault.jpg.
                    // "Rows 1-4 use original small thumbnails + Duration overlay."
                    // default.jpg is small (120x90). mqdefault is 320x180.
                    // For "High-speed", default.jpg is fastest but low res.
                    // I will use mqdefault for better quality on modern phones.
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[900]),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              video.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
