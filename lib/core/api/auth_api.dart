import 'dart:async';

class AuthApi {
  Future<String> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (email.trim().isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (password.length < 4) {
      throw Exception('Invalid credentials');
    }

    return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
  }
}
