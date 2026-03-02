import 'package:flutter/foundation.dart';

@immutable
class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

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

  static final Map<String, UserAccount> _accountsByEmail = {
    'demo@rizz.app': const UserAccount(
      name: 'Demo User',
      email: 'demo@rizz.app',
      password: '123456',
    ),
  };

  static final ValueNotifier<UserAccount?> currentUser =
      ValueNotifier<UserAccount?>(null);

  static bool get isSignedIn => currentUser.value != null;

  static String? signUp({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_accountsByEmail.containsKey(normalizedEmail)) {
      return 'This email is already registered.';
    }

    final account = UserAccount(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );

    _accountsByEmail[normalizedEmail] = account;
    currentUser.value = account;
    return null;
  }

  static String? signIn({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accountsByEmail[normalizedEmail];
    if (account == null || account.password != password) {
      return 'Invalid email or password.';
    }
    currentUser.value = account;
    return null;
  }

  static String? changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final signedInUser = currentUser.value;
    if (signedInUser == null) return 'No active account found.';
    if (signedInUser.password != currentPassword) {
      return 'Current password is incorrect.';
    }

    final updated = signedInUser.copyWith(password: newPassword);
    _accountsByEmail[updated.email] = updated;
    currentUser.value = updated;
    return null;
  }

  static void signOut() {
    currentUser.value = null;
  }
}
