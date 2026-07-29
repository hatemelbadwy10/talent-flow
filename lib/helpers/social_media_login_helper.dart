import 'dart:math' hide log;
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:crypto/crypto.dart';

import '../data/error/api_error_handler.dart';
import '../data/error/failures.dart';

class SocialMediaLoginHelper {
  // Google login
  Future<Either<ServerFailure, SocialMediaModel>> googleLogin() async {
    try {
      log("=====> Provider Google");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS
            ? '863499364117-diha913qm5360v35ml1lpes7qla9ckaf.apps.googleusercontent.com'
            : null,
        scopes: ['email', 'profile'],
      );

      // تأكد إن مفيش سيشن قديم
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return left(ServerFailure("Google sign in cancelled"));
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return left(ServerFailure("Failed to obtain Google ID token"));
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userAccountFirebase =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userAccountFirebase.user == null) {
        return left(ServerFailure("Failed to create Firebase user"));
      }

      // ✅ Get Firebase ID Token (this is what backend needs to verify)
      String? firebaseIdToken;
      try {
        firebaseIdToken = await userAccountFirebase.user!.getIdToken();
      } catch (e) {
        log("=====> Error getting Firebase ID token: $e");
        return left(ServerFailure("Failed to get Firebase ID token: $e"));
      }

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        return left(ServerFailure("Firebase ID token is empty"));
      }

      final SocialMediaModel model = SocialMediaModel();
      model.provider = SocialMediaProvider.google.name;
      model.uid = userAccountFirebase.user?.uid;

      // ✅ Use Firebase ID Token (not Google ID Token)
      model.idToken = firebaseIdToken;

      model.name =
          userAccountFirebase.user?.displayName ?? googleUser.displayName;
      model.image = userAccountFirebase.user?.photoURL ?? googleUser.photoUrl;
      model.email = userAccountFirebase.user?.email ?? googleUser.email;
      model.phone = userAccountFirebase.user?.phoneNumber;

      model.printData();
      return Right(model);
    } on FirebaseAuthException catch (error) {
      log("=====> Firebase Error: ${error.code} - ${error.message}");
      return left(
          ServerFailure(error.message ?? "Firebase authentication failed"));
    } catch (error) {
      log("=====> Error: $error");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  // Apple login
  Future<Either<ServerFailure, SocialMediaModel>> appleLogin() async {
    try {
      log("=====> Provider Apple");

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleUser = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleUser.identityToken == null) {
        return left(ServerFailure("Failed to obtain Apple ID token"));
      }

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleUser.identityToken,
        rawNonce: rawNonce,
      );

      UserCredential userAccountFirebase =
          await FirebaseAuth.instance.signInWithCredential(
        oAuthCredential,
      );

      if (userAccountFirebase.user == null) {
        return left(ServerFailure("Failed to create Firebase user"));
      }

      // ✅ Get Firebase ID Token (this is what backend needs to verify)
      String? firebaseIdToken;
      try {
        firebaseIdToken = await userAccountFirebase.user!.getIdToken();
      } catch (e) {
        log("=====> Error getting Firebase ID token: $e");
        return left(ServerFailure("Failed to get Firebase ID token: $e"));
      }

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        return left(ServerFailure("Firebase ID token is empty"));
      }

      final SocialMediaModel model = SocialMediaModel();

      model.provider = SocialMediaProvider.apple.name;
      model.rawNonce = rawNonce;
      // ✅ Use Firebase ID Token (not Apple ID Token)
      model.idToken = firebaseIdToken;
      model.uid = userAccountFirebase.user?.uid;
      model.email = userAccountFirebase.user?.email;
      model.phone = userAccountFirebase.user?.phoneNumber;
      model.name = userAccountFirebase.user?.displayName;
      model.image = userAccountFirebase.user?.photoURL;
      model.printData();
      return Right(model);
    } on FirebaseAuthException catch (error) {
      log("=====> Firebase Error: ${error.code} - ${error.message}");
      return left(ServerFailure(error.message ?? ""));
    } catch (error) {
      log("=====> Error: $error");
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

enum SocialMediaProvider {
  apple,
  google,
  facebook,
}

class SocialMediaModel {
  String? provider;
  String? idToken;
  String? rawNonce;
  String? uid;
  String? name;
  String? image;
  String? email;
  String? phone;

  void printData() {
    log("provider ==> $provider");
    log("idToken ==> $idToken");
    log("rawNonce ==> $rawNonce");
    log("uid ==> $uid");
    log("name ==> $name");
    log("image ==> $image");
    log("email ==> $email");
    log("phone ==> $phone");
  }
}
