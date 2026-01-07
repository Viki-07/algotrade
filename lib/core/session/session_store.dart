import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  SessionStore({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';

  String? get token => _prefs.getString(_tokenKey);

  Future<void> setToken(String token) => _prefs.setString(_tokenKey, token);

  Future<void> clear() => _prefs.remove(_tokenKey);
}
