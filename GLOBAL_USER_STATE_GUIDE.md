# Global User State Management Guide

## Overview
Your app now has **global user state management** using `UserBloc`. All user-related data (profile, name, email, notifications) is managed centrally and accessible throughout the app without requiring manual refreshes.

## Key Components

### 1. **UserBloc** (Already Configured)
- **Location**: `lib/main_blocs/user_bloc.dart`
- **Status**: Already registered as a global provider in `main.dart`
- **Usage**: Access anywhere in your app via `context.read<UserBloc>()`

### 2. **ProfileCard Widget** (Updated)
- **Location**: `lib/features/setting/widgets/profile_card.dart`
- **Status**: Now uses `UserBloc` for real-time updates
- **Features**:
  - Automatically fetches user data on init
  - Updates when UserBloc state changes
  - Fallbacks to SharedPreferences if needed

### 3. **Global User Header Widgets** (New)
- **Location**: `lib/main_widgets/global_user_header.dart`
- **Available Widgets**:
  - `GlobalUserHeader` - Full header with avatar and name
  - `GlobalUserAvatar` - Just the avatar (with optional notification badge)
  - `GlobalUserName` - Just the name display

## Usage Examples

### In Home Screen Header
```dart
import 'package:talent_flow/main_widgets/global_user_header.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GlobalUserHeader(),
        // or use GlobalUserAvatar for just the image
        // or use GlobalUserName for just the name
      ),
    );
  }
}
```

### In Custom Header
```dart
Row(
  children: [
    const Text('Welcome, '),
    GlobalUserName(
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      showGreeting: false, // Don't show "Hello"
    ),
  ],
)
```

### With Avatar and Notification Badge
```dart
GlobalUserAvatar(
  radius: 28,
  showNotificationBadge: true,
  notificationCount: unreadCount, // Optional
  onTap: () => Navigator.push(...),
)
```

### In Profile Card (Already Done)
```dart
ProfileCard() // Already configured to use UserBloc
```

## How Real-Time Updates Work

### Automatic Updates
1. User logs in → `UserBloc` stores user data
2. Any widget uses `BlocBuilder<UserBloc>` → automatically rebuilds when user data changes
3. No need to manually refresh or navigate back

### Update Triggers
```dart
// Fetch latest user data
context.read<UserBloc>().add(Click());

// Update user info
context.read<UserBloc>().add(Update());

// Sync unread counts (messages, notifications)
context.read<UserBloc>().add(SyncUnreadCounts());
```

### Example: Update Profile
```dart
// In your edit profile page, after saving changes:
context.read<UserBloc>().add(Click()); // Refresh user data
```

All widgets using `BlocBuilder<UserBloc>` will automatically update!

## Best Practices

1. **Always use BlocBuilder** for user-related widgets
```dart
BlocBuilder<UserBloc, AppState>(
  builder: (context, state) {
    final user = context.read<UserBloc>().user;
    return Text(user?.name ?? '');
  },
)
```

2. **Call Click() on init** if you need fresh data
```dart
@override
void initState() {
  super.initState();
  context.read<UserBloc>().add(Click());
}
```

3. **Use fallbacks** for SharedPreferences
```dart
final userName = user?.name ?? prefs.getString(AppStorageKey.userName) ?? 'User';
```

4. **Access globally via instance**
```dart
final userBloc = UserBloc.instance; // Singleton access
```

## Events Available

- `Click()` - Fetch user profile
- `Update()` - Update user info
- `SyncUnreadCounts()` - Sync unread messages/notifications
- `Delete()` - Delete user-related data

## File Structure
```
lib/
  ├── main_blocs/
  │   └── user_bloc.dart (Global user state)
  ├── main_widgets/
  │   └── global_user_header.dart (Reusable user widgets)
  └── features/
      └── setting/
          └── widgets/
              └── profile_card.dart (Profile display)
```

## Migration Checklist

- ✅ ProfileCard updated to use UserBloc
- ✅ Global header widgets created
- ✅ UserBloc already configured as global provider
- [ ] Replace any local user state with these global widgets
- [ ] Update home screen header with GlobalUserHeader
- [ ] Test real-time updates (edit profile → see updates immediately)
