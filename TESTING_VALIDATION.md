# Testing & Validation Guide

## Manual Testing Checklist

### ✅ Test 1: Profile Card Updates
**Scenario**: Edit profile and check if ProfileCard updates automatically

**Steps**:
1. Open Settings screen (should show ProfileCard)
2. Note the current username and email
3. Open Edit Profile
4. Change the name/email
5. Save changes
6. Return to Settings
7. **Expected**: ProfileCard shows new data WITHOUT refresh

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 2: GlobalUserHeader Updates
**Scenario**: Use GlobalUserHeader in home screen

**Steps**:
1. Add `const GlobalUserHeader()` to home screen AppBar
2. Login to app
3. **Expected**: Header shows user name and avatar
4. Edit profile and save
5. **Expected**: Header updates without navigation/refresh

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 3: GlobalUserAvatar Updates
**Scenario**: Upload new profile picture

**Steps**:
1. Add `GlobalUserAvatar(showNotificationBadge: true)` to home screen
2. Upload a new profile picture
3. **Expected**: Avatar updates immediately across app
4. Go to different screens
5. **Expected**: Avatar remains updated everywhere

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 4: Notification Badge Updates
**Scenario**: Receive notification and badge should update

**Steps**:
1. Use `GlobalUserAvatar(showNotificationBadge: true)` in header
2. Receive a notification/message
3. Call: `context.read<UserBloc>().add(SyncUnreadCounts())`
4. **Expected**: Badge shows notification count
5. **Expected**: Badge persists across navigation

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 5: Multiple Widgets Sync
**Scenario**: Multiple user widgets should stay in sync

**Setup**:
```dart
// In home screen
Row(
  children: [
    const GlobalUserAvatar(),
    const GlobalUserName(),
    const GlobalUserHeader(),
    ProfileCard(), // from settings
  ],
)
```

**Steps**:
1. Display all user widgets simultaneously
2. Edit profile from a different screen
3. **Expected**: All 4 widgets update at same time
4. **Expected**: No inconsistent data

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 6: Offline Fallback
**Scenario**: When offline, should use cached data

**Steps**:
1. Turn off internet
2. Navigate to profile screen
3. **Expected**: ProfileCard shows cached user data
4. **Expected**: Avatar shows cached image (if cached_network_image)

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 7: App Restart Persistence
**Scenario**: Data should persist after app restart

**Steps**:
1. Login and navigate to profile
2. Edit profile
3. Fully close app
4. Reopen app
5. **Expected**: Still logged in
6. **Expected**: Profile shows latest data

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 8: Login Flow
**Scenario**: UserBloc should update after login

**Steps**:
1. Start app (not logged in)
2. Login with credentials
3. Call: `context.read<UserBloc>().add(Click())`
4. **Expected**: All widgets show user data
5. Navigate through app
6. **Expected**: Data persists

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 9: Logout Flow
**Scenario**: UserBloc should clear after logout

**Steps**:
1. Logout from settings
2. Call: `context.read<UserBloc>().add(Delete())`
3. Navigate to login
4. **Expected**: No user data shown
5. **Expected**: Login screen appears

**Result**: [ ] Pass [ ] Fail

---

### ✅ Test 10: Performance Test
**Scenario**: App should not lag with global state updates

**Steps**:
1. Edit profile 5 times quickly
2. Each time: call `Click()`
3. **Expected**: No lag or freezing
4. **Expected**: All updates processed smoothly
5. **Expected**: Battery usage reasonable

**Result**: [ ] Pass [ ] Fail

---

## Automated Test Examples

### Test UserBloc Directly
```dart
// In test file
void main() {
  group('UserBloc Tests', () {
    late UserBloc userBloc;
    late MockUserRepo mockUserRepo;

    setUp(() {
      mockUserRepo = MockUserRepo();
      userBloc = UserBloc(repo: mockUserRepo);
    });

    test('Initial state is Start', () {
      expect(userBloc.state, isA<Start>());
    });

    test('Click event fetches user profile', () async {
      when(mockUserRepo.fetchUserProfile()).thenAnswer(
        (_) async => Right(UserModel(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
        )),
      );

      userBloc.add(Click());
      await Future.delayed(Duration(milliseconds: 100));

      expect(userBloc.state, isA<Done>());
      expect(userBloc.user?.name, 'Test User');
    });

    test('Update event syncs user data', () async {
      userBloc.add(Update());
      await Future.delayed(Duration(milliseconds: 100));

      expect(userBloc.state, isA<Done>());
    });
  });
}
```

### Test GlobalUserHeader Widget
```dart
testWidgets('GlobalUserHeader displays user name', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<UserBloc>(
        create: (_) => UserBloc(repo: mockUserRepo),
        child: Scaffold(
          appBar: AppBar(
            title: const GlobalUserHeader(),
          ),
        ),
      ),
    ),
  );

  expect(find.text('Hello'), findsOneWidget);
  expect(find.byType(CircleAvatar), findsOneWidget);
});
```

---

## Integration Testing

### Full User Flow Test
```dart
// Test complete user journey
void testCompleteUserFlow() async {
  // 1. Login
  await loginUser();
  expect(userBloc.isLogin, true);

  // 2. Check profile visible
  expect(find.byType(ProfileCard), findsOneWidget);

  // 3. Edit profile
  await editProfile(name: 'New Name');
  context.read<UserBloc>().add(Click());

  // 4. Verify update
  await Future.delayed(Duration(seconds: 1));
  expect(userBloc.user?.name, 'New Name');

  // 5. Check all widgets updated
  expect(find.text('New Name'), findsWidgets); // Multiple occurrences

  // 6. Logout
  await logout();
  context.read<UserBloc>().add(Delete());
  expect(userBloc.user, null);
}
```

---

## Visual Validation

### Check 1: Profile Card
```
Expected Appearance:
┌─────────────────────────────┐
│ [Avatar] User Name          │
│          user@email.com     │
│          Freelancer         │
├─────────────────────────────┤
│ ✎ Edit Profile              │
│ ⬆ Upload Portfolio          │
│ 📊 Dashboard                │
└─────────────────────────────┘
```

### Check 2: GlobalUserHeader
```
Expected Appearance:
┌─────────────────────────────┐
│ [Avatar] Hello              │
│          John Doe           │
└─────────────────────────────┘
```

### Check 3: Global Avatar with Badge
```
Expected Appearance:
     ┌─────────┐
     │ [Avatar]│
     │     5 🔴│ ← Red badge with count
     └─────────┘
```

---

## Performance Metrics

### What to Measure
- [ ] Time to update UI after `Click()` event
- [ ] Memory usage before/after UserBloc initialization
- [ ] Battery drain with continuous `SyncUnreadCounts()`
- [ ] Network requests (should only happen on `Click()`)
- [ ] Widget rebuild count per update

### Target Benchmarks
- UI update: < 200ms
- Memory per UserBloc: < 5MB
- Rebuild time: < 50ms per widget
- Network calls: 1 per `Click()` event

---

## Error Scenarios to Test

### Scenario 1: Network Error During Click()
```
Expected: 
- Show error message
- User data remains unchanged
- Fallback to SharedPreferences
```

### Scenario 2: Corrupted User Model
```
Expected:
- Fallback to default values
- Don't crash app
- Show generic user info
```

### Scenario 3: Missing Profile Image
```
Expected:
- Show placeholder/app logo
- Don't show broken image
- App remains responsive
```

### Scenario 4: Very Long User Name
```
Expected:
- Name truncates with ellipsis
- Widget still displays properly
- No overflow errors
```

---

## Regression Testing

**After updates, verify:**
- ✓ ProfileCard still updates after edit
- ✓ GlobalUserHeader still shows user data
- ✓ Badges still update on new messages
- ✓ Fallback to SharedPreferences works
- ✓ No duplicate API calls
- ✓ No memory leaks
- ✓ App doesn't crash on logout

---

## Debug Checklist

If something's not working:

1. **Is UserBloc initialized?**
   - Check `main.dart` BlocProvider.value
   - [ ] Yes [ ] No

2. **Is BlocBuilder used?**
   - Should wrap all user data widgets
   - [ ] Yes [ ] No

3. **Is Click() being called?**
   - After edit profile
   - After image upload
   - [ ] Yes [ ] No

4. **Is user data present?**
   - Check: `context.read<UserBloc>().user`
   - [ ] Yes [ ] No (use fallback)

5. **Are routes correct?**
   - Check: Routes.profile, Routes.editProfile, etc.
   - [ ] Yes [ ] No

---

## Quick Validation

Run this in your app:
```dart
// In any screen/widget
void validateGlobalState() {
  print('=== GLOBAL STATE VALIDATION ===');
  
  final userBloc = UserBloc.instance;
  print('UserBloc Instance: $userBloc');
  print('Is Logged In: ${userBloc.isLogin}');
  print('User: ${userBloc.user?.name}');
  print('Has User Data: ${userBloc.user != null}');
  
  final state = userBloc.state;
  print('Current State: $state');
  
  print('=== END VALIDATION ===');
}

// Call from any widget:
// validateGlobalState();
```

---

## Sign-Off Checklist

- [ ] All manual tests pass (10/10)
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Performance acceptable
- [ ] No memory leaks detected
- [ ] Offline mode works
- [ ] App persists data on restart
- [ ] No visual glitches
- [ ] All BlocBuilders updating correctly
- [ ] Ready for production

---

**Status**: Ready to test! Run through these checks to validate the implementation.
