/// Guide: Triggering Real-Time User Updates Across App
///
/// This guide shows how to update the global UserBloc state
/// when user profile changes, ensuring all widgets update automatically

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';

// ============================================================================
// SCENARIO 1: After Editing Profile in Edit Profile Screen
// ============================================================================
class EditProfileExample {
  /// Call this after user successfully edits their profile
  static void onProfileUpdateSuccess(BuildContext context) {
    // Fetch updated user data from server
    context.read<UserBloc>().add(Click());
    
    // Result: All BlocBuilder<UserBloc> widgets automatically rebuild
    // - ProfileCard updates
    // - GlobalUserHeader updates
    // - GlobalUserAvatar updates
    // - GlobalUserName updates
    // - Any other UserBloc listener updates
  }
}

// ============================================================================
// SCENARIO 2: After Uploading Profile Picture
// ============================================================================
class ProfilePictureUploadExample {
  /// Call this after successfully uploading a new profile picture
  static void onProfilePictureUpdated(BuildContext context, String newImageUrl) {
    // Option 1: Fetch fresh user data
    context.read<UserBloc>().add(Click());
    
    // Option 2: Or manually update if you have the image URL
    // This is faster and doesn't require a server call
    final userBloc = context.read<UserBloc>();
    if (userBloc.user != null) {
      userBloc.user!.profileImage = newImageUrl;
      // Emit a new state to trigger rebuilds
      // (You might need to add a method to UserBloc for this)
    }
  }
}

// ============================================================================
// SCENARIO 3: After Name/Bio Change
// ============================================================================
class ProfileInfoUpdateExample {
  /// Call this after updating name, bio, or other profile info
  static void onProfileInfoUpdated(
    BuildContext context, {
    required String? newName,
    required String? newBio,
  }) {
    // Refresh from server
    context.read<UserBloc>().add(Click());
    
    // This will update:
    // - ProfileCard with new name
    // - GlobalUserHeader with new name
    // - Any profile display widget
  }
}

// ============================================================================
// SCENARIO 4: After Login/Registration
// ============================================================================
class LoginRegisterExample {
  /// Call this after successful login or registration
  static void onAuthSuccess(BuildContext context) {
    // Fetch user profile after auth
    context.read<UserBloc>().add(Click());
    
    // All user-dependent widgets will now show correct user info
  }
}

// ============================================================================
// SCENARIO 5: Sync Unread Counts (Messages/Notifications)
// ============================================================================
class SyncUnreadCountsExample {
  /// Call this to update unread notification and message counts
  static void syncUnreadCounts(BuildContext context) {
    context.read<UserBloc>().add(SyncUnreadCounts());
    
    // Result:
    // - Notification badge updates (if using GlobalUserAvatar)
    // - Message badge updates
    // - Any widget watching unreadNotificationsCount or unreadMessagesCount
  }
}

// ============================================================================
// SCENARIO 6: Real-Time Updates from WebSocket/Real-Time Service
// ============================================================================
class RealtimeUpdateExample {
  /// Call this when you receive a real-time update from WebSocket/Pusher
  static void onRealtimeUserUpdate(
    BuildContext context, {
    required Map<String, dynamic> updatedUserData,
  }) {
    // Update the UserBloc with new data
    context.read<UserBloc>().add(Click());
    
    // Or if you want to manually update:
    // Parse the updatedUserData and update user model
    // Then notify listeners
  }
}

// ============================================================================
// PRACTICAL EXAMPLE: Complete Edit Profile Flow
// ============================================================================
class EditProfileCompleteFlow {
  /// Example: In your Edit Profile page, after form submission
  static Future<void> submitProfileChanges(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String bio,
    required String phone,
  }) async {
    try {
      // Show loading
      // (Your implementation)
      
      // Call API to update profile
      final response = await updateProfileAPI(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        phone: phone,
      );
      
      if (response.isSuccess) {
        // SUCCESS: Trigger UserBloc update
        if (context.mounted) {
          context.read<UserBloc>().add(Click());
          
          // Show success message
          // ScaffoldMessenger.of(context).showSnackBar(...);
          
          // Navigate back
          // Navigator.pop(context);
        }
        
        // All widgets automatically update!
        // - ProfileCard shows new name
        // - GlobalUserHeader shows new name
        // - Home page header shows new name
        // No refresh needed!
      } else {
        // ERROR: Show error message
        // (Your implementation)
      }
    } catch (e) {
      // Handle error
      // (Your implementation)
    }
  }
  
  /// Mock API call (replace with actual implementation)
  static Future<ApiResponse> updateProfileAPI({
    required String firstName,
    required String lastName,
    required String bio,
    required String phone,
  }) async {
    // Your actual API call here
    // return await userRepository.updateProfile(...);
    throw UnimplementedError();
  }
}

// ============================================================================
// BEST PRACTICES
// ============================================================================

/// ✅ DO:
/// - Call context.read<UserBloc>().add(Click()) after any user data change
/// - Use BlocBuilder<UserBloc> for all user-related widgets
/// - Store user data in UserBloc, not in local state
/// - Update UserBloc immediately after successful API calls
///
/// ❌ DON'T:
/// - Call setState after updating user data
/// - Store duplicate user data in multiple places
/// - Navigate and expect manual refresh
/// - Ignore UserBloc updates
///
/// ⚡ OPTIMIZATION:
/// - Call SyncUnreadCounts() periodically to keep counts fresh
/// - Cache images to avoid network requests
/// - Use AddWithArguments event if you need to pass data
/// - Implement image caching with cached_network_image

/// ============================================================================
/// INTEGRATION CHECKLIST
/// ============================================================================
/// When you update user data anywhere in your app:
/// 
/// 1. After profile edit:
///    context.read<UserBloc>().add(Click());
/// 
/// 2. After image upload:
///    context.read<UserBloc>().add(Click());
/// 
/// 3. After login/registration:
///    context.read<UserBloc>().add(Click());
/// 
/// 4. When messages received:
///    context.read<UserBloc>().add(SyncUnreadCounts());
/// 
/// 5. When notification received:
///    context.read<UserBloc>().add(SyncUnreadCounts());
/// 
/// Result: Entire app stays in sync automatically! 🎉
