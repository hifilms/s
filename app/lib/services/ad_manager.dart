import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';

class AdManager extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  final StorageService _storageService = StorageService(); // Ideally injected, but for simplicity

  bool get isAdLoaded => _isAdLoaded;

  // Test ID for Android
  final String _testAdId = 'ca-app-pub-3940256099942544/1033173712';

  Future<void> fetchAdConfig() async {
      // Simulate fetching from remote config
      // In real app: final response = await http.get(...)
      await Future.delayed(const Duration(milliseconds: 500));
      // Hypothetical ID
      const remoteId = 'ca-app-pub-3940256099942544/1033173712'; 
      await _storageService.cacheInterstitialId(remoteId);
  }

  Future<void> loadAd() async {
    // Ensure we have the ID (optional, or rely on what's cached/default)
    // await fetchAdConfig(); // Can be called separately in Splash

    // 1-Hour Rule Check
    final lastAdTime = _storageService.getLastAdTime();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final diff = currentTime - lastAdTime;
    const oneHourMs = 60 * 60 * 1000;

    if (diff < oneHourMs) {
      if (kDebugMode) print("Ad blocked: 1 hour rule active.");
      return;
    }

    InterstitialAd.load(
      adUnitId: _storageService.getInterstitialId() ?? _testAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          notifyListeners();
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdLoaded = false;
              _storageService.setLastAdTime(DateTime.now().millisecondsSinceEpoch);
              loadAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdLoaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) print('Ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAdIfAvailable(VoidCallback onCompletion) {
    if (_isAdLoaded && _interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _isAdLoaded = false;
            _storageService.setLastAdTime(DateTime.now().millisecondsSinceEpoch);
            onCompletion(); // Navigate after ad handles
            loadAd(); // Preload next
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _isAdLoaded = false;
            onCompletion(); // Navigate even if error
            loadAd();
          },
        );
        _interstitialAd!.show();
        _interstitialAd = null;
    } else {
      if (kDebugMode) print("Ad not ready or 1 hour rule.");
      onCompletion(); // Navigate immediately
    }
  }
}
