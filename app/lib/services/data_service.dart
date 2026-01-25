import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/video.dart';

class DataService extends ChangeNotifier {
  // Placeholder URL - REPLACE with actual URL
  static const String _dataUrl = 'https://raw.githubusercontent.com/ytdl-org/youtube-dl/master/test/h.json'; // Placeholder
  
  List<HiVideo> _allVideos = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<HiVideo> get allVideos => _allVideos;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Categories
  List<HiVideo> getByCategoryId(int id) => _allVideos.where((v) => v.categoryId == id).toList();
  List<HiVideo> get newReleases => getByCategoryId(1);
  List<HiVideo> get trending => getByCategoryId(2);
  List<HiVideo> get allTimeHits => getByCategoryId(3);
  List<HiVideo> get moods => _allVideos.where((v) => v.categoryId >= 4 && v.categoryId <= 13).toList(); // Approximating 'Moods' as per user request mapping? 
  // Wait, User request said: "Moods Row: Blurred thumbnails + Category Name". 
  // It seems Moods row isn't a list of videos, but a list of Categories? 
  // "Row 5: Moods. Limit: 10 videos per row." - This is ambiguous. 
  // "Moods Row: Blurred thumbnails + Category Name... See All text hidden".
  // Re-reading: "Horizontal Rows: New Release, 2. Trending, 3. All Time Hits, 4. Bookmarks, 5. Moods."
  // If "Moods" is a row of videos, it implies Category 4, 5, etc? 
  // Actually, "Moods" usually implies a list of playlists/categories like "Workout", "Party".
  // "Moods Row: Blurred thumbnails + Category Name (White Bold Center)". This strongly suggests it displays Categories (Workout, Party, Relax...), not videos.
  // The user listed Mapping 4-13 as genres/moods? 4. Workout ... 13. Kids.
  // So Row 5 "Moods" should display these Categories as cards.
  
  Future<void> fetchData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // In a real app we might check connectivity first or use a try-catch on the http call
      final response = await http.get(Uri.parse(_dataUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allVideos = data.map((e) => HiVideo.fromArray(e)).toList();
        _isLoading = false;
        
        // Cache data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_h_json', response.body);
        
        notifyListeners();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Try loading from cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? cachedString = prefs.getString('cached_h_json');
        
        if (cachedString != null && cachedString.isNotEmpty) {
           final List<dynamic> data = json.decode(cachedString);
           _allVideos = data.map((e) => HiVideo.fromArray(e)).toList();
           _isLoading = false;
           notifyListeners();
           if (kDebugMode) print("App loaded from cache");
           return;
        }
      } catch (cacheError) {
         if (kDebugMode) print("Cache failed: $cacheError");
      }

      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
