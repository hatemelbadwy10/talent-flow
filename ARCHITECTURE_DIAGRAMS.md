# Global User State Architecture

## System Overview

```
┌────────────────────────────────────────────────────────────────┐
│                       App (main.dart)                          │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  BlocProvider.value(UserBloc.instance) - GLOBAL PROVIDER │ │
│  └──────────────────┬───────────────────────────────────────┘ │
│                     │                                         │
└─────────────────────┼─────────────────────────────────────────┘
                      │
         ┌────────────┴─────────────┐
         │                          │
    ┌────▼────────┐            ┌────▼─────────┐
    │   UserBloc   │            │ SharedPrefs  │
    │ (State Mgmt) │            │   (Fallback) │
    └────┬────────┘            └──────────────┘
         │
    ┌────▼────────────────────────────┐
    │    Available Everywhere via:     │
    │  context.read<UserBloc>()        │
    │  or                              │
    │  UserBloc.instance               │
    └────┬────────────────────────────┘
         │
    ┌────▼─────────────────────────────────────────────────┐
    │           Any Widget Can Listen To Updates           │
    │                                                      │
    │  BlocBuilder<UserBloc, AppState>(                   │
    │    builder: (context, state) { ... }                │
    │  )                                                   │
    │                                                      │
    └─┬──┬──────┬──────────┬────────────┬────────────┐    │
      │  │      │          │            │            │    │
    ┌─▼──▼──┐┌──▼────────┐┌───▼───────┐┌──▼────────┐│
    │Profile││ProfileCard││GlobalUser ││Home       ││
    │Screen ││           ││Header     ││Screen     ││
    └───────┘└───────────┘└───────────┘└───────────┘│
    │
    └──────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
USER ACTION
    │
    ▼
Edit Profile / Upload Image / Login / etc.
    │
    ▼
API Call / Update
    │
    ▼
On Success:
context.read<UserBloc>().add(Click())
    │
    ▼
UserBloc Fetches Fresh User Data
    │
    ▼
UserBloc.user = UserModel(...)
Emit(Done) ← State changes
    │
    ▼
ALL BlocBuilder<UserBloc> Widgets Rebuild:
┌──────────────────────────────────────────┐
│ ✓ ProfileCard                            │
│ ✓ GlobalUserHeader                       │
│ ✓ GlobalUserAvatar                       │
│ ✓ GlobalUserName                         │
│ ✓ Any other listener                     │
└──────────────────────────────────────────┘
    │
    ▼
UI Shows Latest User Data
```

## Widget Hierarchy

```
MyApp
│
├─ BlocProvider.value<UserBloc>
│  │
│  ├─ HomeScreen
│  │  │
│  │  ├─ ExampleHomeHeader (Uses GlobalUserHeader)
│  │  │  ├─ GlobalUserHeader (BlocBuilder<UserBloc>)
│  │  │  ├─ Notification Icon (BlocBuilder<UserBloc>)
│  │  │  └─ Message Icon (BlocBuilder<UserBloc>)
│  │  │
│  │  └─ Body
│  │
│  ├─ SettingsScreen
│  │  │
│  │  └─ ProfileCard (BlocBuilder<UserBloc>)
│  │     ├─ CircleAvatar (with UserBloc.user.profileImage)
│  │     ├─ User Name (with UserBloc.user.name)
│  │     ├─ User Email (with UserBloc.user.email)
│  │     └─ Options
│  │
│  └─ EditProfileScreen
│     └─ (Updates UserBloc after save)
│
└─ Other Routes...
```

## UserBloc State Machine

```
                    ┌─────────────┐
                    │   Start()   │
                    └──────┬──────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
        Click()        Update()      SyncUnreadCounts()
            │              │              │
            ▼              ▼              ▼
        ┌─────────┐    ┌──────────┐  ┌──────────┐
        │Loading()│    │Loading() │  │Loading() │
        └────┬────┘    └────┬─────┘  └────┬─────┘
             │              │             │
    ┌────────┴──────────┐   │             │
    │                   │   │             │
    ▼                   ▼   ▼             ▼
┌────────┐          ┌──────────┐     ┌────────┐
│Done()  │─────────▶│Done()    │────▶│Done()  │
│(with   │          │(updated) │     │(counts │
│UserModel)         │          │     │updated)│
└────┬───┘          └──────────┘     └────────┘
     │                   │                │
     └───────────────────┴────────────────┘
             │
             ▼
        All Listeners
        Receive Update
             │
             ▼
        Widgets Rebuild
```

## Event Types

```
┌─────────────────┐
│   AppEvent      │
└────────┬────────┘
         │
    ┌────┴─────────────────────────────┐
    │                                  │
┌───▼────────┐  ┌──────────────┐  ┌───▼────────┐
│Click()     │  │Update()      │  │Delete()    │
│(Fetch)     │  │(Sync user)   │  │(Clear)     │
└────────────┘  └──────────────┘  └────────────┘
    │               │                  │
    ▼               ▼                  ▼
Fetch from    Update existing    Clear user
server        user model         data
```

## Real-Time Update Scenarios

### Scenario 1: Edit Profile Flow
```
EditProfileScreen
    │
    ├─ User enters new name
    ├─ User taps Save
    │
    ▼ (on success)
context.read<UserBloc>().add(Click())
    │
    ▼
UserBloc fetches fresh data
    │
    ▼ (emit Done)
ALL Widgets Update:
    ├─ ProfileCard shows new name ✓
    ├─ GlobalUserHeader shows new name ✓
    ├─ HomeScreen header shows new name ✓
    └─ All other listeners update ✓
```

### Scenario 2: Upload Avatar Flow
```
ImageUploadScreen
    │
    ├─ User selects image
    ├─ Image uploads to server
    │
    ▼ (on success)
context.read<UserBloc>().add(Click())
    │
    ▼
UserBloc fetches fresh data with new image
    │
    ▼ (emit Done)
ALL Avatar Widgets Update:
    ├─ ProfileCard avatar ✓
    ├─ GlobalUserAvatar ✓
    ├─ HomeScreen header avatar ✓
    └─ All other listeners ✓
```

### Scenario 3: Notification/Message Received
```
WebSocket/Pusher
    │
    ├─ Message received
    │
    ▼
context.read<UserBloc>().add(SyncUnreadCounts())
    │
    ▼
UserBloc syncs unread counts
    │
    ▼ (emit Done)
ALL Badge Widgets Update:
    ├─ GlobalUserAvatar badge ✓
    ├─ ExampleHomeHeader badges ✓
    ├─ Any notification listener ✓
    └─ Message count displays ✓
```

## Performance Implications

```
❌ Old Approach (Without Global State)
┌────────────┐
│ HomeScreen │─────┐
└────────────┘     │ (Needs manual refresh)
┌────────────┐     │
│ Profile    │◀────┤ (Each has own state)
│ Screen     │     │
└────────────┘     │
┌────────────┐     │
│ Edit       │────▶┤ (No auto-sync)
│ Profile    │     │
└────────────┘     │
               Must navigate
               back to refresh

✅ New Approach (With Global State)
┌────────────┐
│ HomeScreen │─┐
└────────────┘ │
┌────────────┐ │ All share
│ Profile    │─┼─ UserBloc
│ Screen     │ │ (Automatic
└────────────┘ │  sync)
┌────────────┐ │
│ Edit       │─┤ No navigation
│ Profile    │─┘ needed!
└────────────┘
```

## Memory Model

```
App Startup:
    │
    ├─ UserBloc created (Singleton)
    │  └─ UserRepo initialized
    │     └─ SharedPreferences initialized
    │
    ├─ BlocProvider wraps all routes
    │
    └─ Ready to use everywhere!

During Runtime:
    │
    ├─ UserBloc instance available via:
    │  ├─ context.read<UserBloc>()
    │  ├─ context.watch<UserBloc>() (rebuilds on change)
    │  └─ UserBloc.instance (direct access)
    │
    └─ Data cached in:
       ├─ UserBloc.user (Memory)
       └─ SharedPreferences (Persistent)
```

---

This architecture ensures that user state is:
- ✅ Centralized (one source of truth)
- ✅ Reactive (widgets auto-update)
- ✅ Persistent (survives app restart)
- ✅ Global (accessible everywhere)
- ✅ Efficient (no duplicate data)
