import 'dart:developer' as dev;
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/error/api_error_handler.dart';
import '../data/error/failures.dart';

class SocialMediaLoginHelper {
  //Google login
  Future<Either<ServerFailure, SocialMediaModel>> googleLogin() async {
    try {
      dev.log("=====> Provider Google");
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userAccountFirebase =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final SocialMediaModel model = SocialMediaModel();
      model.provider = SocialMediaProvider.google.name;
      model.uid = userAccountFirebase.user?.uid;
      model.idToken = googleAuth?.accessToken;
      model.name = googleUser?.displayName;
      model.image = googleUser?.photoUrl;
      model.email = googleUser?.email;
      model.phone = userAccountFirebase.user?.phoneNumber;

      model.printData();
      return Right(model);
    } on FirebaseAuthException catch (error) {
      return left(ServerFailure(error.message ?? ""));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  //Facebook login
  Future<Either<ServerFailure, SocialMediaModel>> facebookLogin() async {
    try {
      dev.log("=====> Provider FacebookAuth");

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ["email", "public_profile"],
      );

      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken? facebookAuth = result.accessToken;
        try {
          // Create a credential from the access token
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(
            facebookAuth!.tokenString,
          );

          // Once signed in, return the UserCredential
          UserCredential userAccountFirebase =
              await FirebaseAuth.instance.signInWithCredential(
            facebookAuthCredential,
          );

          final SocialMediaModel model = SocialMediaModel();
          model.provider = SocialMediaProvider.facebook.name;
          model.idToken = facebookAuth.tokenString;
          model.uid = userAccountFirebase.user?.uid;
          model.name = userAccountFirebase.user?.displayName;
          model.image = userAccountFirebase.user?.photoURL;
          model.email = userAccountFirebase.user?.email;
          model.phone = userAccountFirebase.user?.phoneNumber;
          model.printData();
          return Right(model);
        } on FirebaseAuthException catch (error) {
          return left(ApiErrorHandler.getServerFailure(error));
        } catch (error) {
          return left(ApiErrorHandler.getServerFailure(error));
        }
      } else {
        return left(ServerFailure("${result.message}"));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  //Apple login
  Future<Either<ServerFailure, SocialMediaModel>> appleLogin() async {
    try {
      dev.log("=====> Provider Apple");

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleUser = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleUser.identityToken,
        rawNonce: rawNonce,
      );

      //
      UserCredential userAccountFirebase =
          await FirebaseAuth.instance.signInWithCredential(
        oAuthCredential,
      );

      final SocialMediaModel model = SocialMediaModel();

      model.provider = SocialMediaProvider.apple.name;
      model.rawNonce = rawNonce;
      model.idToken = appleUser.identityToken;
      model.uid = userAccountFirebase.user?.uid;
      model.email = userAccountFirebase.user?.email;
      model.phone = userAccountFirebase.user?.phoneNumber;
      model.name = userAccountFirebase.user?.displayName;
      model.image = userAccountFirebase.user?.photoURL;
      model.printData();
      return Right(model);
    } on FirebaseAuthException catch (error) {
      return left(ServerFailure(error.message ?? ""));
    } catch (error) {
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
    dev.log("provider ==> $provider");
    dev.log("idToken ==> $idToken");
    dev.log("rawNonce ==> $rawNonce");
    dev.log("uid ==> $uid");
    dev.log("name ==> $name");
    dev.log("image ==> $image");
    dev.log("email ==> $email");
    dev.log("phone ==> $phone");
  }
}