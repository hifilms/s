import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../../models/video.dart';
import '../widgets/horizontal_video_list.dart';
import '../widgets/moods_row.dart';
import '../widgets/decades_grid.dart';

class HomeListRows extends StatelessWidget {
  const HomeListRows({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        if (dataService.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final allVideos = dataService.allVideos;
        if (allVideos.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        // Row 1: New Release (Cat 1)
        final newReleases = dataService.newReleases.take(10).toList();
        
        // Row 2: Trending (Cat 2)
        final trending = dataService.trending.take(10).toList();
        
        // Row 3: All Time Hits (Cat 3)
        final allTimeHits = dataService.allTimeHits.take(10).toList();
        
        // Row 4: Bookmarks (Cat 22) - Logic: Default hidden. Appears only after first bookmark.
        final storageService = Provider.of<StorageService>(context);
        final bookmarkIds = storageService.getBookmarks();
        final bookmarkedVideos = allVideos.where((v) => bookmarkIds.contains(v.id)).take(10).toList();
        
        // Moods (Cat 4-13)
        // Need representative video for the category thumbnail
        final List<HiVideo> moodCategories = [];
        for (int i = 4; i <= 13; i++) {
           final videos = dataService.getByCategoryId(i);
           if (videos.isNotEmpty) moodCategories.add(videos.first);
        }

        // Decades (Cat 14-21)
        final List<HiVideo> decadeCategories = [];
        for (int i = 14; i <= 21; i++) {
           final videos = dataService.getByCategoryId(i);
           if (videos.isNotEmpty) decadeCategories.add(videos.first);
        }

        return SliverList(
          delegate: SliverChildListDelegate([
            if (newReleases.isNotEmpty)
              HorizontalVideoList(title: "New Release", videos: newReleases),
            
            if (trending.isNotEmpty)
              HorizontalVideoList(title: "Trending", videos: trending),

            if (allTimeHits.isNotEmpty)
              HorizontalVideoList(title: "All Time Hits", videos: allTimeHits),
            
            // Bookmarks (Row 4)
            if (bookmarkedVideos.isNotEmpty)
              HorizontalVideoList(title: "Bookmarks", videos: bookmarkedVideos),
            
            // Moods (Row 5 - effectively if Bookmarks present, else Row 4 visually but technically next)
            if (moodCategories.isNotEmpty)
              MoodsRow(moodVideos: moodCategories),
            
            // Decades (Bottom)
            if (decadeCategories.isNotEmpty)
              DecadesGrid(decadeVideos: decadeCategories),
            
            const SizedBox(height: 100), // Bottom padding
          ]),
        );
      },
    );
  }
}
