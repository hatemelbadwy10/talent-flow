# 🚀 Quick Reference: Global User State

## Copy-Paste Solutions

### 1️⃣ Use Global Header in Home Screen
```dart
import 'package:talent_flow/main_widgets/global_user_header.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GlobalUserHeader(),
      ),
    );
  }
}
```

### 2️⃣ Use in Custom AppBar
```dart
AppBar(
  title: const GlobalUserName(showGreeting: true),
  leading: const GlobalUserAvatar(radius: 20),
)
```

### 3️⃣ Use in Header Section
```dart
Row(
  children: [
    const GlobalUserAvatar(
      radius: 28,
      showNotificationBadge: true,
    ),
    const SizedBox(width: 12),
    const Expanded(
      child: GlobalUserName(showGreeting: true),
    ),
  ],
)
```

### 4️⃣ After Profile Edit - Trigger Update
```dart
// In your edit profile save button
onPressed: () async {
  // Save changes to API
  await updateUserProfile(...);
  
  // Refresh user data in all widgets
  if (context.mounted) {
    context.read<UserBloc>().add(Click());
  }
  
  // Navigate back
  Navigator.pop(context);
}
```

### 5️⃣ After Image Upload - Trigger Update
```dart
// After uploading profile picture
if (uploadSuccess) {
  if (context.mounted) {
    context.read<UserBloc>().add(Click());
  }
}
```

### 6️⃣ Show Notification Badge
```dart
GlobalUserAvatar(
  radius: 24,
  showNotificationBadge: true,
  notificationCount: 5, // Optional
  onTap: () => Navigator.push(...),
)
```

### 7️⃣ Custom Styling
```dart
GlobalUserHeader(
  showUserImage: true,
  showUserName: true,
  userImageRadius: 30,
  userNameStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  onUserTap: () {
    // Custom navigation
    CustomNavigator.push(Routes.profile);
  },
)
```

### 8️⃣ Just the Avatar (Minimal)
```dart
const GlobalUserAvatar(
  radius: 24,
  onTap: () => CustomNavigator.push(Routes.profile),
)
```

### 9️⃣ Just the Name (Minimal)
```dart
const GlobalUserName(
  showGreeting: false,
  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)
```

### 🔟 Complete Example Home Header
```dart
import 'package:talent_flow/main_widgets/example_home_header.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ExampleHomeHeader(), // Full featured header
          // Rest of screen
        ],
      ),
    );
  }
}
```

---

## Common Update Triggers

### After Any User Data Change:
```dart
context.read<UserBloc>().add(Click());
```

### Update Unread Counts:
```dart
context.read<UserBloc>().add(SyncUnreadCounts());
```

### After Login:
```dart
context.read<UserBloc>().add(Click());
```

### After Logout:
```dart
context.read<UserBloc>().add(Delete());
```

---

## Files to Know

| File | Purpose |
|------|---------|
| `lib/main_blocs/user_bloc.dart` | Global user state (already exists) |
| `lib/main_widgets/global_user_header.dart` | Reusable widgets |
| `lib/main_widgets/example_home_header.dart` | Example implementations |
| `lib/features/setting/widgets/profile_card.dart` | Updated with UserBloc |

---

## Key Points

✅ ProfileCard automatically updates - no changes needed
✅ Use GlobalUserHeader/Avatar/Name anywhere in your app
✅ Call `context.read<UserBloc>().add(Click())` to refresh
✅ All widgets update simultaneously
✅ No manual navigation or refresh needed
✅ Works with notifications and messages

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Widget not updating | Call `Click()` event |
| Avatar not showing | Check `UserModel.profileImage` |
| Badge not updating | Call `SyncUnreadCounts()` event |
| Old data showing | Clear cache or refresh UserBloc |

---

## Performance Tips

1. Use `GlobalUserAvatar` alone for better performance
2. Cache images with `cached_network_image`
3. Don't update too frequently
4. Use `SyncUnreadCounts()` periodically, not on every action

---

**That's it! You now have a fully functional global user state system.** 🎉
