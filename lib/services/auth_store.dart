import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

@immutable
class UserAccount {
  const UserAccount({required this.name, required this.email, this.password});

  final String name;
  final String email;
  final String? password;

  UserAccount copyWith({String? name, String? email, String? password}) {
    return UserAccount(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class AuthStore {
  AuthStore._();

  static final ValueNotifier<UserAccount?> currentUser =
      ValueNotifier<UserAccount?>(null);

  static const String _googleClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '1097226990560-gn232sovgrhdfpg1fhsn32ur4a9mqf12.apps.googleusercontent.com',
  );
  static const String _facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  static bool _initialized = false;

  static bool get isSignedIn => currentUser.value != null;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb && _facebookAppId.isNotEmpty) {
      FacebookAuth.i.webAndDesktopInitialize(
        appId: _facebookAppId,
        cookie: true,
        xfbml: true,
        version: 'v22.0',
      );
    }

    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser.value = null;
        return;
      }

      final account = await _accountFromFirebaseUser(firebaseUser);
      currentUser.value = account;
    });
  }

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim().toLowerCase(),
            password: password,
          );

      final user = credential.user;
      if (user == null) {
        return 'Sign up failed. Please try again.';
      }

      await user.updateDisplayName(name.trim());
      await _saveUserProfile(user.uid, name.trim(), user.email ?? email);

      currentUser.value = UserAccount(
        name: name.trim(),
        email: (user.email ?? email).trim().toLowerCase(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (_) {
      return 'Could not create account. Please try again.';
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return 'Sign in failed. Please try again.';
      }

      final account = await _accountFromFirebaseUser(
        user,
        fallbackPassword: password,
      );
      currentUser.value = account;
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (_) {
      return 'Could not sign in. Please check your internet connection.';
    }
  }

  static Future<String?> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignInClient().signIn();
        if (googleUser == null) {
          return 'Google sign-in was cancelled.';
        }

        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await FirebaseAuth.instance.signInWithCredential(
          authCredential,
        );
      }

      final user = credential.user;
      if (user == null) {
        return 'Google sign-in failed. Please try again.';
      }

      final resolvedName = _resolvedDisplayName(user);
      await _saveUserProfile(user.uid, resolvedName, user.email ?? '');

      final account = await _accountFromFirebaseUser(user);
      currentUser.value = account;
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } on PlatformException catch (e) {
      return _providerPlatformErrorMessage('Google', e);
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return 'Could not sign in with Google. Please try again.';
    }
  }

  static Future<String?> signInWithFacebook() async {
    try {
      if (kIsWeb && _facebookAppId.isEmpty) {
        return 'FACEBOOK_APP_ID is missing. Run with '
            '--dart-define=FACEBOOK_APP_ID=<your-facebook-app-id>.';
      }

      UserCredential credential;

      if (kIsWeb) {
        final provider = FacebookAuthProvider();
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final loginResult = await FacebookAuth.instance.login(
          permissions: const ['email', 'public_profile'],
        );

        if (loginResult.status == LoginStatus.cancelled) {
          return 'Facebook sign-in was cancelled.';
        }
        if (loginResult.status == LoginStatus.failed) {
          final reason = loginResult.message?.trim();
          return reason == null || reason.isEmpty
              ? 'Facebook sign-in failed. Please try again.'
              : reason;
        }

        final accessToken = loginResult.accessToken?.tokenString;
        if (accessToken == null || accessToken.isEmpty) {
          return 'Facebook did not return a valid access token.';
        }

        final authCredential = FacebookAuthProvider.credential(accessToken);
        credential = await FirebaseAuth.instance.signInWithCredential(
          authCredential,
        );
      }

      final user = credential.user;
      if (user == null) {
        return 'Facebook sign-in failed. Please try again.';
      }

      final resolvedName = _resolvedDisplayName(user);
      await _saveUserProfile(user.uid, resolvedName, user.email ?? '');

      final account = await _accountFromFirebaseUser(user);
      currentUser.value = account;
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } on PlatformException catch (e) {
      return _providerPlatformErrorMessage('Facebook', e);
    } catch (e, stackTrace) {
      debugPrint('Facebook sign-in error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return 'Could not sign in with Facebook. Please try again.';
    }
  }

  static Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return 'No active account found.';
    }

    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );
    if (!hasPasswordProvider) {
      return 'This account uses social sign-in. Add email/password in account '
          'settings before changing password.';
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      final existing = currentUser.value;
      if (existing != null) {
        currentUser.value = existing.copyWith(password: newPassword);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (_) {
      return 'Could not update password. Please try again.';
    }
  }

  static void signOut() {
    FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      FacebookAuth.instance.logOut();
      _googleSignInClient().signOut();
    }
    currentUser.value = null;
  }

  static Future<UserAccount> _accountFromFirebaseUser(
    User user, {
    String? fallbackPassword,
  }) async {
    final profile = await _readUserProfile(user.uid);

    final rawName = profile?['name'];
    final nameFromDb = rawName is String ? rawName.trim() : '';
    final resolvedName = nameFromDb.isNotEmpty
        ? nameFromDb
        : _resolvedDisplayName(user);

    return UserAccount(
      name: resolvedName,
      email: (user.email ?? '').trim().toLowerCase(),
      password: fallbackPassword,
    );
  }

  static String _resolvedDisplayName(User user) {
    final displayName = user.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final email = user.email?.trim() ?? '';
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'User';
  }

  static GoogleSignIn _googleSignInClient() {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return GoogleSignIn(clientId: _googleClientId);
    }
    return GoogleSignIn();
  }

  static Future<Map<String, dynamic>?> _readUserProfile(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return snapshot.data();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveUserProfile(
    String uid,
    String name,
    String email,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'account-exists-with-different-credential':
        return 'This email already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again and retry changing password.';
      default:
        return error.message ?? 'Authentication request failed.';
    }
  }

  static String _providerPlatformErrorMessage(
    String providerName,
    PlatformException error,
  ) {
    final details =
        '${error.code} ${error.message ?? ''} ${error.details ?? ''}'
            .toLowerCase();

    if (providerName == 'Google' &&
        (details.contains('apiexception: 10') ||
            details.contains('developer_error'))) {
      return 'Google OAuth setup is invalid (DEVELOPER_ERROR). Add SHA-1 and '
          'SHA-256 in Firebase, then download a fresh google-services.json.';
    }

    if (details.contains('network_error')) {
      return '$providerName sign-in failed due to a network error.';
    }

    return '$providerName sign-in failed (${error.code}).';
  }
}
