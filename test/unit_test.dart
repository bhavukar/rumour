import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumour/components/app_back_button.dart';
import 'package:rumour/components/shimmer.dart';
import 'package:rumour/components/user_avatar.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:rumour/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:rumour/features/chat/presentation/widgets/swipe_to_reply.dart';
import 'package:rumour/features/room/data/model/random_user_response_model.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/user_model.dart';
import 'package:rumour/features/settings/presentation/view/settings_screen.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/network/connectivity_cubit.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:rumour/services/theme/theme_cubit.dart';
import 'package:rumour/features/room/presentation/bloc/room_event.dart';
import 'package:rumour/features/room/presentation/bloc/room_state.dart';
import 'package:rumour/features/room/presentation/widgets/identity_sheet.dart';
import 'package:rumour/features/room/presentation/widgets/room_code_input.dart';
import 'package:rumour/features/room/presentation/widgets/join_or_create_sheet.dart';
import 'package:rumour/features/room/presentation/view/splash_screen.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/utilities/date_formatter.dart';
import 'package:rumour/services/firebase/api_error.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rumour/utilities/handle_generator.dart';
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
  group('LoggerService Tests', () {
    test('LoggerService handles debug, info, warn, error without throwing', () {
      expect(() => LoggerService.debug('Test debug message', tag: 'UnitTest'),
          returnsNormally);
      expect(() => LoggerService.info('Test info message', tag: 'UnitTest'),
          returnsNormally);
      expect(() => LoggerService.warn('Test warning message', tag: 'UnitTest'),
          returnsNormally);
      expect(
        () => LoggerService.error(
          'Test error message',
          tag: 'UnitTest',
          error: Exception('Test exception'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
  group('HandleGenerator Tests', () {
    test('generateFallbackHandle returns non-empty handle with two words', () {
      final handle = HandleGenerator.generateFallbackHandle();
      expect(handle.isNotEmpty, isTrue);
      expect(handle.split(' ').length, greaterThanOrEqualTo(2));
    });

    test('toMentionTag prepends @ and removes spaces', () {
      expect(
          HandleGenerator.toMentionTag('Brave Badger'), equals('@BraveBadger'));
      expect(HandleGenerator.toMentionTag('@PinkPanthress'),
          equals('@PinkPanthress'));
    });
  });

  group('DateFormatter Tests', () {
    test('formatDateSeparator returns Today for current date', () {
      final now = DateTime.now();
      expect(DateFormatter.formatDateSeparator(now), equals('Today'));
    });

    test('formatDateSeparator returns Yesterday for 1 day ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatDateSeparator(yesterday), equals('Yesterday'));
    });

    test('isSameDay correctly identifies matching days', () {
      final d1 = DateTime(2026, 11, 4, 10, 30);
      final d2 = DateTime(2026, 11, 4, 18, 45);
      final d3 = DateTime(2026, 11, 5, 10, 30);

      expect(DateFormatter.isSameDay(d1, d2), isTrue);
      expect(DateFormatter.isSameDay(d1, d3), isFalse);
    });
  });

  group('RandomUser DTO Tests', () {
    test('parses strongly-typed DTO from map without hardcoding errors', () {
      final rawMap = {
        'results': [
          {
            'name': {'title': 'Mr', 'first': 'Pink', 'last': 'Panther'},
            'login': {'uuid': 'uuid-123', 'username': 'PinkPanthress'},
            'picture': {'medium': 'https://example.com/pic.jpg'},
          }
        ]
      };

      final model = RandomUserResponseModel.fromJson(rawMap);
      expect(model.results.length, equals(1));
      expect(model.results.first.name.first, equals('Pink'));
      expect(model.results.first.login.username, equals('PinkPanthress'));
      expect(model.results.first.picture?.medium,
          equals('https://example.com/pic.jpg'));
    });
  });

  group('RoomIdentityModel Tests', () {
    test('serializes and deserializes correctly', () {
      final model = RoomIdentityModel(
        id: 'user-123',
        roomId: '5812',
        displayName: 'Brave Badger',
        mentionTag: '@BraveBadger',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

      final jsonMap = model.toJson();
      final decodedModel = RoomIdentityModel.fromJson(jsonMap);

      expect(decodedModel.id, equals(model.id));
      expect(decodedModel.roomId, equals(model.roomId));
      expect(decodedModel.displayName, equals(model.displayName));
      expect(decodedModel.mentionTag, equals(model.mentionTag));
      expect(decodedModel.avatarUrl, equals(model.avatarUrl));
    });
  });

  group('ChatMessageModel Tests', () {
    test('isMine returns true when senderId matches currentUserId', () {
      final model = ChatMessageModel(
        id: 'msg-1',
        roomId: '5812',
        senderId: 'user-abc',
        senderName: 'Brave Badger',
        senderMention: '@BraveBadger',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        text: 'Hello world',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

      expect(model.isMine('user-abc'), isTrue);
      expect(model.isMine('user-xyz'), isFalse);
      expect(model.senderAvatarUrl, equals('https://example.com/avatar.jpg'));
      expect(model.toFirestore()['senderAvatarUrl'],
          equals('https://example.com/avatar.jpg'));
    });

    test('serializes and preserves replyTo metadata correctly', () {
      final replyModel = ChatMessageModel(
        id: 'msg-reply',
        roomId: '5812',
        senderId: 'user-xyz',
        senderName: 'Quiet Wolf',
        senderMention: '@QuietWolf',
        text: 'This is a reply message',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000050000),
        replyToId: 'msg-1',
        replyToSenderName: 'Brave Badger',
        replyToText: 'Hello world',
      );

      expect(replyModel.isReply, isTrue);
      expect(replyModel.replyToId, equals('msg-1'));
      expect(replyModel.replyToSenderName, equals('Brave Badger'));
      expect(replyModel.replyToText, equals('Hello world'));

      final payload = replyModel.toFirestore();
      expect(payload['replyToId'], equals('msg-1'));
      expect(payload['replyToSenderName'], equals('Brave Badger'));
      expect(payload['replyToText'], equals('Hello world'));
    });

    test('isPending defaults to false and propagates through copyWith', () {
      final model = ChatMessageModel(
        id: 'msg-offline',
        roomId: '5812',
        senderId: 'user-abc',
        senderName: 'Brave Badger',
        senderMention: '@BraveBadger',
        text: 'Queued message',
        createdAt: DateTime.now(),
        isPending: true,
      );

      expect(model.isPending, isTrue);
      expect(model.copyWith.isPending(false).isPending, isFalse);
    });

    test('isSystem returns true when type is system and false for text', () {
      final systemMsg = ChatMessageModel(
        id: 'msg-sys-1',
        roomId: '963FNH',
        senderId: 'user-abc',
        senderName: 'Brave Bison',
        senderMention: '@bravebison',
        text: 'Brave Bison joined the room',
        createdAt: DateTime.now(),
        type: 'system',
      );
      expect(systemMsg.isSystem, isTrue);

      final textMsg = ChatMessageModel(
        id: 'msg-txt-1',
        roomId: '963FNH',
        senderId: 'user-abc',
        senderName: 'Brave Bison',
        senderMention: '@bravebison',
        text: 'Hello everyone!',
        createdAt: DateTime.now(),
        type: 'text',
      );
      expect(textMsg.isSystem, isFalse);
    });
  });

  group('SwipeToReply Widget Tests', () {
    testWidgets('renders child and triggers onReply on horizontal swipe',
        (tester) async {
      bool replied = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: Center(
              child: SwipeToReply(
                onReply: () => replied = true,
                child: const Text('Swipeable Message'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Swipeable Message'), findsOneWidget);

      // Perform swipe right past trigger threshold (40px)
      await tester.drag(
          find.text('Swipeable Message'), const Offset(65.0, 0.0));
      await tester.pumpAndSettle();

      expect(replied, isTrue);
    });
  });

  group('UserModel Tests', () {
    test('UserModel serializes to create and update firestore payloads', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'anon_user_123',
        isAnonymous: true,
        createdAt: now,
        lastSeenAt: now,
        displayName: 'Secret Agent',
        avatarUrl: 'https://example.com/photo.png',
      );

      final createPayload = user.toFirestoreCreate();
      expect(createPayload['id'], equals('anon_user_123'));
      expect(createPayload['isAnonymous'], isTrue);
      expect(createPayload['displayName'], equals('Secret Agent'));
      expect(
          createPayload['avatarUrl'], equals('https://example.com/photo.png'));
      expect(createPayload.containsKey('createdAt'), isTrue);
      expect(createPayload.containsKey('lastSeenAt'), isTrue);

      final updatePayload = user.toFirestoreUpdate();
      expect(updatePayload.containsKey('id'), isFalse);
      expect(updatePayload.containsKey('createdAt'), isFalse);
      expect(updatePayload['displayName'], equals('Secret Agent'));
      expect(
          updatePayload['avatarUrl'], equals('https://example.com/photo.png'));
      expect(updatePayload.containsKey('lastSeenAt'), isTrue);
    });
  });

  group('ConnectivityState Tests', () {
    test('ConnectivityState correctly computes isConnected and isDisconnected',
        () {
      const onlineState =
          ConnectivityState(status: ConnectivityStatus.connected);
      expect(onlineState.isConnected, isTrue);
      expect(onlineState.isDisconnected, isFalse);

      const offlineState = ConnectivityState(
          status: ConnectivityStatus.disconnected, wasDisconnected: true);
      expect(offlineState.isConnected, isFalse);
      expect(offlineState.isDisconnected, isTrue);
      expect(offlineState.wasDisconnected, isTrue);
    });

    test('ConnectivityState copyWith updates fields predictably', () {
      const state = ConnectivityState(status: ConnectivityStatus.connected);
      final updated = state.copyWith(
          status: ConnectivityStatus.disconnected, wasDisconnected: true);

      expect(updated.status, equals(ConnectivityStatus.disconnected));
      expect(updated.wasDisconnected, isTrue);
    });
  });

  group('ThemeCubit Tests', () {
    test('defaults to ThemeMode.dark and toggles to light and persists',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);

      final cubit = ThemeCubit(localStorageService: storage);
      expect(cubit.state, equals(ThemeMode.dark));
      expect(cubit.isDarkMode, isTrue);

      cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.light));
      expect(cubit.isDarkMode, isFalse);
      expect(storage.prefs.getString('app_theme_mode'), equals('light'));

      cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.dark));
      expect(storage.prefs.getString('app_theme_mode'), equals('dark'));
    });

    test(
        'AppThemeColors dark and light presets have proper contrast and semantic shades',
        () {
      expect(AppThemeColors.dark.surface.s50,
          isNot(equals(AppThemeColors.light.surface.s50)));
      expect(AppThemeColors.dark.onSurface.s900,
          isNot(equals(AppThemeColors.light.onSurface.s900)));
      expect(AppThemeColors.dark.primary.s500, equals(const Color(0xFFC6FE1E)));
      expect(AppThemeColors.dark.onPrimary, equals(const Color(0xFF000000)));
      expect(AppThemeColors.dark.surface.s50, equals(const Color(0xFF0C0D11)));
      expect(
          AppThemeColors.light.primary.s500, equals(const Color(0xFFB5F200)));
    });
  });

  group('RoomEvent and RoomState Tests', () {
    test('CreateRoomSubmitted equality and props', () {
      const e1 = CreateRoomSubmitted();
      const e2 = CreateRoomSubmitted();
      expect(e1, equals(e2));
      expect(e1.props, isEmpty);
    });

    test('RoomCreating state equality and props', () {
      const s1 = RoomCreating();
      const s2 = RoomCreating();
      expect(s1, equals(s2));
      expect(s1.props, isEmpty);
    });
  });

  group('UserAvatar Widget Tests', () {
    testWidgets('renders initials when avatarUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(displayName: 'Brave Badger'),
          ),
        ),
      );
      expect(find.text('BB'), findsOneWidget);
    });

    testWidgets('renders single initial if one short word', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(displayName: 'A'),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('ChatBubble Widget Tests', () {
    testWidgets('renders outgoing message with You label and lime bubble',
        (tester) async {
      final msg = ChatMessageModel(
        id: 'msg-1',
        roomId: 'TEST',
        senderId: 'me',
        senderName: 'Brave Badger',
        senderMention: '@BraveBadger',
        text: 'Heyy',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AppThemeColors.dark],
          ),
          home: Scaffold(
            body: ChatBubble(
              message: msg,
              isMine: true,
            ),
          ),
        ),
      );

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Heyy'), findsOneWidget);
    });

    testWidgets('renders incoming message with mention handle', (tester) async {
      final msg = ChatMessageModel(
        id: 'msg-2',
        roomId: 'TEST',
        senderId: 'other',
        senderName: 'Pink Panthress',
        senderMention: '@PinkPanthress',
        text: 'Hello from city',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AppThemeColors.dark],
          ),
          home: Scaffold(
            body: ChatBubble(
              message: msg,
              isMine: false,
            ),
          ),
        ),
      );

      expect(find.text('@PinkPanthress'), findsOneWidget);
      expect(find.text('Hello from city'), findsOneWidget);
    });
  });

  group('SettingsScreen and Storage Tests', () {
    testWidgets(
        'renders SettingsScreen with single unified App Settings: Appearance, Notifications, Storage, and About',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);
      final cubit = ThemeCubit(localStorageService: storage);

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: ThemeData.dark()
                .copyWith(extensions: const [AppThemeColors.dark]),
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Appearance Theme'), findsOneWidget);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('DATA & STORAGE'), findsOneWidget);
      expect(find.text('Clear App Data'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Rumour'), findsOneWidget);

      // Verify NO confusing UUID / Anonymous User ID or duplicated Leave Room in App Settings
      expect(find.text('Anonymous User ID'), findsNothing);
      expect(find.text('Leave Room'), findsNothing);
    });

    test(
        'LocalStorageService clearAllSessionData wipes active room, identities, and cache',
        () async {
      SharedPreferences.setMockInitialValues({
        'active_room_code': 'ABC123',
        'joined_room_codes': ['ABC123', 'XYZ789'],
        'room_identity_ABC123': '{"id":"test"}',
        'cached_messages_ABC123': ['{"id":"msg1"}'],
        'theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);

      await storage.clearAllSessionData();

      expect(storage.getActiveRoom(), isNull);
      expect(storage.getJoinedRooms(), isEmpty);
      expect(storage.getRoomIdentity('ABC123'), isNull);
      expect(storage.getCachedMessagesJson('ABC123'), isEmpty);
      expect(prefs.getString('theme_mode'), 'dark'); // preserved
    });
  });

  group('IdentitySheet Tests', () {
    testWidgets(
        'renders IdentitySheet with giant gradient title and NO avatar circle',
        (tester) async {
      bool acknowledged = false;
      final identity = RoomIdentityModel(
        id: 'user-identity-test',
        roomId: '8821',
        displayName: 'Brave Badger',
        mentionTag: '@BraveBadger',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: IdentitySheet(
              identity: identity,
              onAcknowledge: () => acknowledged = true,
            ),
          ),
        ),
      );

      // Verify header subtitle
      expect(find.text('For this room, you are'), findsOneWidget);

      // Verify persona name formatted on two lines
      expect(find.text('Brave\nBadger'), findsOneWidget);

      // Verify explanation text
      expect(
        find.text(
            'This is your anonymous identifier, visible only to others in this room.'),
        findsOneWidget,
      );

      // Verify NO avatar is rendered in the sheet
      expect(find.byType(UserAvatar), findsNothing);

      // Verify acknowledge button is present and triggers callback
      final ackButton = find.text('Acknowledge and continue');
      expect(ackButton, findsOneWidget);
      await tester.tap(ackButton);
      await tester.pump();
      expect(acknowledged, isTrue);
    });
  });

  group('Shimmer Loading Tests', () {
    testWidgets('renders ChatLoadingSkeleton correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: const Scaffold(
            body: ChatLoadingSkeleton(),
          ),
        ),
      );

      expect(find.byType(ChatLoadingSkeleton), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ShimmerBox), findsWidgets);
    });

    testWidgets('renders RoomActionShimmer with loading status text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: const Scaffold(
            body: RoomActionShimmer(text: 'Creating anonymous room...'),
          ),
        ),
      );

      expect(find.text('Creating anonymous room...'), findsOneWidget);
      expect(find.byType(ShimmerBox), findsOneWidget);
    });
  });

  group('Active Room and Logout Session Tests', () {
    test('LocalStorageService manages active room lifecycle correctly',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);

      expect(storage.getActiveRoom(), isNull);

      await storage.saveActiveRoom('room-5432');
      expect(storage.getActiveRoom(), equals('ROOM-5432'));

      await storage.clearActiveRoom();
      expect(storage.getActiveRoom(), isNull);
    });

    test('NotificationService.clearOnLogout handles graceful execution',
        () async {
      // Must not throw even without Firebase initialization in unit tests
      await expectLater(
        NotificationService.clearOnLogout(roomCode: '5432'),
        completes,
      );
    });
  });

  group('AppBackButton Tests', () {
    testWidgets('renders AppBackButton and responds to tap', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            appBar: AppBar(
              leading: AppBackButton(
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });

  group('ChatInputBar Tests', () {
    testWidgets('renders centered pill with hint text and triggers onSend',
        (tester) async {
      String? sentText;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: ChatInputBar(
              onSend: (text) => sentText = text,
            ),
          ),
        ),
      );

      expect(find.text('Type a message'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello Rumour');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.near_me_rounded));
      await tester.pump();

      expect(sentText, equals('Hello Rumour'));
    });
  });

  group('ChatBubble Offline Queue and Admin Badge Tests', () {
    testWidgets('renders clock icon when message isPending is true',
        (tester) async {
      final message = ChatMessageModel(
        id: 'msg-pending',
        roomId: '5812',
        senderId: 'user-me',
        senderName: 'Pink Panther',
        senderMention: '@PinkPanther',
        text: 'Queued offline message',
        createdAt: DateTime.now(),
        isPending: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: ChatBubble(
              message: message,
              isMine: true,
              isAdmin: true,
            ),
          ),
        ),
      );

      expect(find.text('Queued offline message'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
    });

    testWidgets(
        'renders checkmarks icon when message is synced (isPending false)',
        (tester) async {
      final message = ChatMessageModel(
        id: 'msg-synced',
        roomId: '5812',
        senderId: 'user-other',
        senderName: 'Quiet Wolf',
        senderMention: '@QuietWolf',
        text: 'Synced incoming message',
        createdAt: DateTime.now(),
        isPending: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: ChatBubble(
              message: message,
              isMine: false,
            ),
          ),
        ),
      );

      expect(find.text('Synced incoming message'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsNothing);
    });
  });

  group('HapticService Tests', () {
    test('HapticService methods execute gracefully without throwing', () async {
      await expectLater(HapticService.light(), completes);
      await expectLater(HapticService.medium(), completes);
      await expectLater(HapticService.heavy(), completes);
      await expectLater(HapticService.selection(), completes);
    });
  });

  group('Responsive Layout & Zoom Overflow Tests', () {
    testWidgets(
        'RoomCodeInput renders without horizontal overflow on narrow 320px screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: RoomCodeInput(
                  onChanged: (_) {},
                  onCompleted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'RoomActionShimmer renders long loading text without overflow on narrow screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: RoomActionShimmer(
                  text: 'Creating anonymous room...',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Creating anonymous room...'), findsOneWidget);
    });

    testWidgets(
        'IdentitySheet renders without overflow on compact 520px height',
        (tester) async {
      tester.view.physicalSize = const Size(360, 520);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final identity = RoomIdentityModel(
        id: 'test-user',
        roomId: 'A9686D',
        displayName: 'Quantum Quokka',
        mentionTag: '@QuantumQuokka',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: IdentitySheet(
              identity: identity,
              onAcknowledge: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Acknowledge and continue'), findsOneWidget);
    });
  });

  group('SplashScreen and Route Decision Tests', () {
    testWidgets('SplashScreen renders Rumour title and loading indicator',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: const SplashScreen(),
        ),
      );

      expect(find.text('Rumour'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Joined Rooms and Sheet Tests', () {
    test('LocalStorageService manages joined rooms list correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);

      expect(storage.getJoinedRooms(), isEmpty);

      await storage.addJoinedRoom('A9686D');
      await storage.addJoinedRoom('R5Y4UL');

      final list = storage.getJoinedRooms();
      expect(list.length, equals(2));
      expect(list.first, equals('R5Y4UL')); // Most recently joined on top

      // Re-joining or opening an already joined room must preserve stable order without jumping
      await storage.addJoinedRoom('A9686D');
      expect(storage.getJoinedRooms(), equals(['R5Y4UL', 'A9686D']));

      await storage.removeJoinedRoom('R5Y4UL');
      expect(storage.getJoinedRooms(), equals(['A9686D']));
    });

    test('DateFormatter.formatRelativeTime returns expected labels', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelativeTime(now), equals('Just now'));
      expect(
          DateFormatter.formatRelativeTime(
              now.subtract(const Duration(minutes: 5))),
          equals('5m'));
      expect(
          DateFormatter.formatRelativeTime(
              now.subtract(const Duration(hours: 3))),
          equals('3h'));
    });

    testWidgets('JoinOrCreateSheet renders create button and code input',
        (tester) async {
      bool createTriggered = false;
      String? joinedCode;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark()
              .copyWith(extensions: const [AppThemeColors.dark]),
          home: Scaffold(
            body: JoinOrCreateSheet(
              onCreate: () => createTriggered = true,
              onJoin: (code) => joinedCode = code,
            ),
          ),
        ),
      );

      expect(find.text('Create a New Room'), findsOneWidget);
      expect(find.text('OR JOIN WITH CODE'), findsOneWidget);
      expect(find.text('Join Room'), findsOneWidget);

      await tester.tap(find.text('Create a New Room'));
      expect(createTriggered, isTrue);
      expect(joinedCode, isNull);
    });
  });

  group('CrashlyticsService and AnalyticsService Tests', () {
    test('CrashlyticsService methods execute safely without throwing',
        () async {
      await CrashlyticsService.initialize();
      CrashlyticsService.setUserIdentifier('test-user-id');
      CrashlyticsService.setCustomKey('active_room', 'ABCDEF');
      CrashlyticsService.log('test breadcrumb log');
      CrashlyticsService.recordError(
          'test non-fatal error', StackTrace.current);
    });

    test('AnalyticsService methods execute safely without throwing', () async {
      await AnalyticsService.initialize();
      await AnalyticsService.setUserId('test-user-id');
      await AnalyticsService.logRoomCreated('ABCDEF');
      await AnalyticsService.logRoomJoined('ABCDEF');
      await AnalyticsService.logRoomLeft('ABCDEF');
      await AnalyticsService.logMessageSent(
        roomCode: 'ABCDEF',
        messageLength: 20,
        isReply: false,
      );
      await AnalyticsService.logScreenView('chat_room');
      await AnalyticsService.logThemeChanged('dark');
      await AnalyticsService.logAppDataCleared();
    });
  });

  group('ApiError and Firebase Exception Mapping Tests', () {
    test('maps permission-denied to friendly room permission message', () {
      final err = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      );
      final apiError = ApiError.fromException(err);
      expect(apiError.code, equals('permission-denied'));
      expect(
          apiError.userMessage, contains('permission to perform this action'));
    });

    test('maps unavailable to service reconnecting message', () {
      final err = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'The service is currently unavailable.',
      );
      final apiError = ApiError.fromException(err);
      expect(apiError.code, equals('unavailable'));
      expect(apiError.userMessage, contains('temporarily unavailable'));
    });

    test('maps not-found to room or message not found message', () {
      final err = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
      );
      final apiError = ApiError.fromException(err);
      expect(apiError.code, equals('not-found'));
      expect(apiError.userMessage, contains('could not be found'));
    });

    test('maps already-exists to room code collision message', () {
      final err = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
      );
      final apiError = ApiError.fromException(err);
      expect(apiError.code, equals('already-exists'));
      expect(apiError.userMessage, contains('already active'));
    });

    test('maps network errors and socket exceptions cleanly', () {
      final sockErr = const SocketException('Failed host lookup');
      final apiError = ApiError.fromException(sockErr);
      expect(apiError.code, equals('no_internet'));
      expect(apiError.userMessage, contains('No internet connection'));
    });

    test('maps timeout exception to connection timeout message', () {
      final timeoutErr = TimeoutException('Operation timed out');
      final apiError = ApiError.fromException(timeoutErr);
      expect(apiError.code, equals('timeout'));
      expect(apiError.userMessage, contains('Connection timed out'));
    });

    test('maps unexpected errors without crashing', () {
      final randomErr = Exception('Unknown cryptic error');
      final apiError = ApiError.fromException(randomErr);
      expect(apiError.code, equals('unexpected_error'));
      expect(apiError.userMessage, contains('Something went wrong'));
    });
  });
}
