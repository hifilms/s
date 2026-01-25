class HiVideo {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final int categoryId;
  final String categoryName;

  HiVideo({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.categoryId,
    required this.categoryName,
  });

  factory HiVideo.fromArray(List<dynamic> array) {
    // Array format: ["Video_ID", "Title", "Artist", "Duration", Cat_No]
    final catId = array[4] is int ? array[4] : int.tryParse(array[4].toString()) ?? 0;
    return HiVideo(
      id: array[0].toString(),
      title: array[1].toString(),
      artist: array[2].toString(),
      duration: array[3].toString(),
      categoryId: catId,
      categoryName: _getCategoryName(catId),
    );
  }

  static String _getCategoryName(int id) {
    switch (id) {
      case 1: return "New Release";
      case 2: return "Trending";
      case 3: return "All Time Hits";
      case 4: return "Workout";
      case 5: return "Party";
      case 6: return "Relax";
      case 7: return "Love";
      case 8: return "Road Trip";
      case 9: return "Focus";
      case 10: return "Hip-Hop";
      case 11: return "Rock";
      case 12: return "Country";
      case 13: return "Kids";
      case 14: return "2020s";
      case 15: return "2010s";
      case 16: return "2000s";
      case 17: return "90s";
      case 18: return "80s";
      case 19: return "70s";
      case 20: return "60s";
      case 21: return "50s";
      case 22: return "Bookmarks"; // Defined in Step 4
      default: return "Unknown";
    }
  }

  // Helper for thumbnails
  String get thumbnailMaxRes => "https://img.youtube.com/vi/$id/maxresdefault.jpg";
  String get thumbnailMq => "https://img.youtube.com/vi/$id/mqdefault.jpg";
}
