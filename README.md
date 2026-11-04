# Rumour

Anonymous room-code real-time chat application built with Flutter, BLoC, and Cloud Firestore.

---

## Deliverables

- Working APK: [releases/rumour-v1.0.0.apk](releases/rumour-v1.0.0.apk)
- Universal APK (All ABIs): [releases/rumour-universal-v1.0.0.apk](releases/rumour-universal-v1.0.0.apk)
- Video Demonstration: [Watch Complete Workflow Video](VIDEO_LINK_HERE)

---

## Codebase Structure

```
lib/
├── components/                  # Shared UI components
│   ├── app_back_button.dart     # Back navigation button
│   ├── app_badge.dart           # Status badge
│   ├── app_button.dart          # Primary action button
│   ├── connectivity_banner.dart # Offline status indicator
│   ├── date_separator.dart      # Day boundary pill
│   ├── drop_down.dart           # Custom selection dropdown
│   ├── loading_indicator.dart   # Loading indicator
│   ├── room_avatar.dart         # Deterministic gradient avatar
│   ├── shimmer.dart             # Placeholder loading skeleton
│   ├── text_input.dart          # Form text input
│   └── user_avatar.dart         # User initials avatar
├── config/themes/               # Design and styling configuration
│   ├── app_colors.dart          # Color constants
│   ├── app_theme_colors.dart    # Theme extensions for light/dark switching
│   ├── app_theme.dart           # Material ThemeData definitions
│   └── app_typography.dart      # Typographic scale
├── features/
│   ├── chat/                    # Real-time chat module
│   │   ├── data/
│   │   │   ├── model/           # ChatMessageModel DTO
│   │   │   ├── repositories/    # ChatRepository (caching, streams, pagination)
│   │   │   └── source/          # ChatRemoteSource (Firestore queries and writes)
│   │   └── presentation/
│   │       ├── bloc/            # ChatBloc, ChatEvent, ChatState
│   │       ├── view/            # ChatRoomScreen
│   │       └── widgets/         # ChatBubble, ChatInputBar, SwipeToReply
│   ├── room/                    # Room lifecycle and onboarding module
│   │   ├── data/
│   │   │   ├── model/           # RoomModel, RoomMemberModel, RoomIdentityModel
│   │   │   ├── repositories/    # RoomRepository (creation, joining, identities)
│   │   │   └── source/          # RoomRemoteSource and RoomLocalSource
│   │   └── presentation/
│   │       ├── bloc/            # RoomBloc, RoomEvent, RoomState
│   │       ├── view/            # JoinRoomScreen, SplashScreen
│   │       └── widgets/         # IdentitySheet, JoinOrCreateSheet, RoomMembersSheet
│   └── settings/                # User and application settings
│       └── presentation/view/   # SettingsScreen
├── services/                    # Infrastructure services
│   ├── analytics/               # Firebase Analytics telemetry
│   ├── crashlytics/             # Firebase Crashlytics error boundary
│   ├── dependency_injection/    # Service and BLoC locator wiring
│   ├── firebase/                # Firebase core initialization and ApiError mapper
│   ├── haptics/                 # Platform haptic feedback
│   ├── logger/                  # Structured console and remote logging
│   ├── network/                 # Connectivity status watcher
│   ├── notifications/          # FCM client and local notifications
│   ├── routes/                  # AppRouter (GoRouter setup)
│   ├── storage/                 # LocalStorageService (SharedPreferences)
│   └── theme/                   # ThemeCubit (Light and Dark mode)
└── utilities/                   # Helper utilities
    ├── date_formatter.dart      # Relative and chat timestamp formatting
    ├── handle_generator.dart    # Fallback persona generator
    ├── room_name_generator.dart # Room initials and name generator
    └── timestamp_converter.dart # Firestore Timestamp JSON serialization
```

---

## Firebase Cloud Firestore Data Structure

```
rooms/ (collection)
  └── {roomCode}/ (document, e.g. "963FNH")
        ├── code: string                 # 6-character room identifier
        ├── memberCount: number          # Total active room participants
        ├── createdAt: timestamp         # Server timestamp of room creation
        ├── createdBy: string            # Firebase UID of the room creator
        ├── lastMessageAt: timestamp     # Timestamp of the latest message
        ├── lastMessageText: string      # Snippet of the latest message
        ├── lastMessageSender: string    # Display name of the latest sender
        ├── lastMessageSenderId: string  # User ID of the latest sender
        │
        ├── members/ (subcollection)
        │     └── {userId}/ (document)
        │           ├── displayName: string   # Generated persona name
        │           ├── mentionTag: string    # Formatted @mention tag
        │           ├── avatarUrl: string?    # Optional persona photo URL
        │           └── joinedAt: timestamp   # Server timestamp of joining
        │
        └── messages/ (subcollection)
              └── {messageId}/ (document)
                    ├── text: string          # Message content
                    ├── senderId: string      # Author user ID
                    ├── senderName: string    # Author display name
                    ├── senderMention: string # Formatted @mention tag
                    ├── senderAvatarUrl: str? # Optional author avatar URL
                    ├── type: string          # "text" or "system"
                    ├── replyToId: string?    # Quoted message ID for replies
                    ├── replyToSenderName: s? # Quoted author display name
                    ├── replyToText: string?  # Quoted text snippet
                    └── createdAt: timestamp  # Server timestamp (indexed descending)
```

---

## Additional Features Implemented

### 1. Push Notifications via Cloudflare Edge Worker
- Subscribes devices to topic `room_{ROOM_CODE}` upon joining or creating a room.
- Dispatch is handled by an edge worker running on Cloudflare Workers (`https://rumour-fcm.bhavuk-arora03.workers.dev/notify`).
- Generates an RS256 Google OAuth2 token at the edge and broadcasts directly to FCM v1 REST API.
- Operates 24/7 without requiring Firebase Blaze plan or background desktop daemons.
- Suppresses foreground notifications if the user is currently viewing the active chat room.
- Tapping notifications navigates directly into the target room without stacking duplicate routes.

### 2. Offline Persistence and Optimistic UI
- Instant local retrieval: Previously joined rooms and their message histories are stored via `LocalStorageService` (SharedPreferences) and load immediately on launch without waiting for network connectivity.
- Optimistic dispatch: Outgoing messages appear immediately with a pending clock indicator and update to synced checkmarks once committed to Firestore.
- Network banner: Displays an adaptive connection warning banner when device connectivity drops and reconnects automatically when network restores.

### 3. Per-Room Identity and Session Persistence
- Identity fetched per-room from `https://randomuser.me/api/` with an algorithmic two-word fallback (`Adjective + Animal`).
- Persists locally per room: Rejoining a previously visited room restores the original assigned identity without consuming new identities.
- New identities are introduced via a docked bottom sheet (`IdentitySheet`) anchored to the bottom of the screen.

### 4. Real-Time Chat Features
- Date separators (`Today`, `Yesterday`, or formatted calendar dates).
- System event chips: Non-intrusive centered chips for member joins without message bubble clutter.
- Consecutive message grouping: Merges bubbles from the same author sent within close intervals.
- Swipe-to-reply: Native horizontal drag gesture on any message to trigger a reply snippet.
- Deterministic room avatars: Algorithmic 2-to-3 color gradients hashed from the room code, ensuring all participants see identical room colors online and offline.
- Room list highlights: Room tiles format latest messages as `@sender : message`, with the sender handle highlighted in the primary accent.

### 5. Production Observability and Error Handling
- Firebase Crashlytics: Captures Flutter UI exceptions, uncaught asynchronous platform errors, and logs breadcrumbs.
- Firebase Analytics: Records screen views, room creation, joins, departures, and message telemetry.
- ApiError Handler: Standardized mapping of Firestore codes (`permission-denied`, `unavailable`, `not-found`, `already-exists`, `resource-exhausted`), network timeouts, and socket errors into clean user messages.
- Account identifier: Settings displays the current Firebase anonymous User ID with a one-tap copy button.

### 6. Themes and Styling
- Dark mode and light mode with animated transition switch.
- Strict design compliance: Borderless containers, flat card surfaces, and semantic typography tokens.

---

## Testing

The project includes 53 automated unit and widget tests covering DTO serialization, BLoC state transitions, offline storage, date utilities, error handling, and responsive rendering down to 320px width.

To run the automated test suite:

```bash
flutter test
```

To run static analysis:

```bash
flutter analyze lib/
```

---

## Build Instructions

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.8+
- Android Studio / Xcode

### Run Application
```bash
# Copy environment configuration
cp .env.example .env

flutter pub get
flutter run
```

### Build Release APK
```bash
# Per-ABI APK (recommended for smaller download size)
flutter build apk --release --split-per-abi

# Universal APK
flutter build apk --release
```
