import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/video.dart';
import '../../services/data_service.dart';
import '../../services/ad_manager.dart';
import '../../services/audio_service.dart';

class HeroSlider extends StatefulWidget {
  const HeroSlider({super.key});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  final PageController _controller = PageController();
  List<HiVideo> _heroVideos = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectRandomVideos();
  }

  void _selectRandomVideos() {
    final allVideos = context.read<DataService>().allVideos;
    if (allVideos.isEmpty) return;

    // Logic: 10 random videos from 10 different categories if possible
    final Map<int, HiVideo> categoryMap = {};
    for (var v in allVideos) {
      if (!categoryMap.containsKey(v.categoryId)) {
        categoryMap[v.categoryId] = v;
      }
    }
    
    // If we have enough categories, pick one from each. Else fill with random.
    List<HiVideo> selection = categoryMap.values.toList();
    selection.shuffle();
    if (selection.length > 10) selection = selection.sublist(0, 10);
    
    // If not enough unique categories, fill with random unique videos
    if (selection.length < 10) {
       final remaining = 10 - selection.length;
       final usedIds = selection.map((e) => e.id).toSet();
       final others = allVideos.where((v) => !usedIds.contains(v.id)).toList();
       others.shuffle();
       selection.addAll(others.take(remaining));
    }

    setState(() {
      _heroVideos = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_heroVideos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _heroVideos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final video = _heroVideos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailMq, // User requested mqdefault for Hero? "Use mqdefault.jpg thumbnails"
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[900]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: GestureDetector( // Added tap detection on text area or whole stack?
                      onTap: () {
                         context.read<AdManager>().showAdIfAvailable(() {
                             context.read<AudioService>().playVideo(video, contextPlaylist: _heroVideos);
                         });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${video.categoryName} | ${video.artist}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ); // Closes Stack
            },
          ),
          // Slide Counter
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_currentIndex + 1}/${_heroVideos.length}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
