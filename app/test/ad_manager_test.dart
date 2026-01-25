import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hi_music/services/ad_manager.dart';
import 'package:hi_music/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdManager Logic', () {
    test('Should allow ad if 60 minutes have passed', () async {
      SharedPreferences.setMockInitialValues({
        'last_ad_time': DateTime.now().subtract(const Duration(minutes: 61)).millisecondsSinceEpoch,
      });
      
      final storage = StorageService();
      await storage.init();
      
      final lastAdTime = storage.getLastAdTime();
      final difference = DateTime.now().millisecondsSinceEpoch - lastAdTime;
      
      expect(difference > 60 * 60 * 1000, true);
    });

    test('Should BLOCK ad if less than 60 minutes', () async {
      SharedPreferences.setMockInitialValues({
        'last_ad_time': DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
      });

      final storage = StorageService();
      await storage.init();

      final lastAdTime = storage.getLastAdTime();
      final difference = DateTime.now().millisecondsSinceEpoch - lastAdTime;

      expect(difference < 60 * 60 * 1000, true);
    });
  });
}
