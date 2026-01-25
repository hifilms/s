import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../services/audio_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = context.watch<AudioService>();
    final currentVideo = audioService.currentVideo;

    if (currentVideo == null || !audioService.showPlayer) return const SizedBox.shrink();

    return GestureDetector(
      onTap: audioService.maximize,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Colors.grey[800]!)),
        ),
        child: Row(
          children: [
            // Left: Live Video Thumbnail
            // "Live Video Thumbnail (Non-interactive)"
            // If I put the YoutubePlayer here, it reparents from the Main Player?
            // YouTube IFrame Controller can only start one view. 
            // If I move the widget here, it works.
            // So if minimized -> Render Player here. If maximized -> Render Player in PlayerScreen.
            // This requires the Player Widget to be passed around or conditional rendering.
             SizedBox(
               width: 120,
               child: IgnorePointer( // Non-interactive to taps on video
                 child: YoutubePlayer(
                    controller: audioService.controller,
                    aspectRatio: 16/9,
                 ),
               ),
             ),
            
            // Center: Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentVideo.title, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentVideo.artist,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            // Right: Prev/Play/Next
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white), 
                  onPressed: audioService.prev,
                ),
                IconButton(
                  icon: Icon(audioService.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), 
                  onPressed: audioService.togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white), 
                  onPressed: audioService.next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
