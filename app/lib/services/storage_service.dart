import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Bookmarks
  List<String> getBookmarks() {
    return _prefs.getStringList('bookmarks') ?? [];
  }

  Future<void> toggleBookmark(String videoId) async {
    final List<String> bookmarks = getBookmarks();
    if (bookmarks.contains(videoId)) {
      bookmarks.remove(videoId);
    } else {
      bookmarks.add(videoId);
    }
    await _prefs.setStringList('bookmarks', bookmarks);
    notifyListeners();
  }

  bool isBookmarked(String videoId) {
    return getBookmarks().contains(videoId);
  }


  // AdMob
  Future<void> cacheInterstitialId(String id) async {
    await _prefs.setString('interstitial_ad_id', id);
  }

  String? getInterstitialId() {
    return _prefs.getString('interstitial_ad_id');
  }

  Future<void> setLastAdTime(int timestamp) async {
    await _prefs.setInt('last_ad_time', timestamp);
  }
  
  int getLastAdTime() {
    return _prefs.getInt('last_ad_time') ?? 0;
  }
}
