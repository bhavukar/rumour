import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumour/services/dependency_injection/app_config.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: '''
FIREBASE_API_KEY_ANDROID=test_api_key_android
FIREBASE_APP_ID_ANDROID=1:1234567890:android:test
FIREBASE_API_KEY_IOS=test_api_key_ios
FIREBASE_APP_ID_IOS=1:1234567890:ios:test
FIREBASE_PROJECT_ID=rumour-anon-chat
FIREBASE_MESSAGING_SENDER_ID=382375200319
FIREBASE_STORAGE_BUCKET=rumour-anon-chat.firebasestorage.app
FCM_NOTIFY_ENDPOINT=https://example.com/notify
''');
  });
  testWidgets(
      'Smoke test for JoinRoomScreen initial render with AppConfiguration and AppRouter',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs: prefs);

    await tester.pumpWidget(
      AppConfiguration(
        localStorageService: storage,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Join A Room'), findsOneWidget);
    expect(find.textContaining('Enter the code to join the anon chat'),
        findsOneWidget);
  });
}
