import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/video.dart';

class AudioService extends ChangeNotifier {
  HiVideo? _currentVideo;
  List<HiVideo> _playlist = [];
  bool _isPlaying = false;
  bool _isMinimized = true; // Start hidden or minimized
  bool _showPlayer = false; // To hide initially
  
  late YoutubePlayerController _controller;

  HiVideo? get currentVideo => _currentVideo;
  List<HiVideo> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  bool get isMinimized => _isMinimized;
  bool get showPlayer => _showPlayer;
  YoutubePlayerController get controller => _controller;

  AudioService() {
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false, // Custom controls
        showFullscreenButton: false,
        mute: false,
        captionLanguage: 'en',
      ),
    );
    
    _controller.listen((event) {
       // Loop/Auto-play logic
       if (event.playerState == PlayerState.ended) {
          next();
       }
       if (event.playerState == PlayerState.playing) {
         _isPlaying = true;
         notifyListeners();
       } else if (event.playerState == PlayerState.paused) {
         _isPlaying = false;
         notifyListeners();
       }
    });
  }

  void playVideo(HiVideo video, {List<HiVideo>? contextPlaylist}) {
    _currentVideo = video;
    if (contextPlaylist != null) _playlist = contextPlaylist;
    
    _controller.loadVideoById(videoId: video.id);
    _showPlayer = true;
    _isMinimized = false; // Expand on click
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _controller.pauseVideo();
    } else {
      _controller.playVideo();
    }
  }

  void next() {
    if (_currentVideo == null || _playlist.isEmpty) return;
    final index = _playlist.indexOf(_currentVideo!);
    if (index < _playlist.length - 1) {
      playVideo(_playlist[index + 1]);
    } else {
       // Loop to start? Or stop? 
       // "Auto-Play: Move to next song automatically when finished."
       // Usually implies playlist continuation.
    }
  }

  void prev() {
    if (_currentVideo == null || _playlist.isEmpty) return;
    final index = _playlist.indexOf(_currentVideo!);
    if (index > 0) {
      playVideo(_playlist[index - 1]);
    }
  }

  void minimize() {
    _isMinimized = true;
    notifyListeners();
  }

  void maximize() {
    _isMinimized = false;
    notifyListeners();
  }

  void close() {
    _showPlayer = false;
    _controller.stopVideo();
    notifyListeners();
  }
}
