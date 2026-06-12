import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api.dart';

class AuthProvider extends ChangeNotifier {
  String? token, role, email, fullname;
  int? userId;
  bool loading = false;

  bool get isLoggedIn => token != null;
  bool get isAdmin => role == 'admin';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(AppConstants.tokenKey);
    role = p.getString(AppConstants.roleKey);
    userId = p.getInt(AppConstants.userIdKey);
    email = p.getString(AppConstants.emailKey);
    fullname = p.getString(AppConstants.nameKey);
    notifyListeners();
  }

  Future<String> login(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      final d = await Api().login(email, password);

      final p = await SharedPreferences.getInstance();

      token = d['token'];
      role = d['role'];
      userId = d['userId'];
      this.email = d['email'];
      fullname = d['fullname'];

      await p.setString(AppConstants.tokenKey, token!);
      await p.setString(AppConstants.roleKey, role!);
      await p.setInt(AppConstants.userIdKey, userId!);
      await p.setString(AppConstants.emailKey, this.email!);
      await p.setString(AppConstants.nameKey, fullname!);

      notifyListeners();
      return role!;
    } on ApiException catch (e) {
      throw e; // important
    } catch (e) {
      throw ApiException("Erreur inconnue");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    token = role = email = fullname = null;
    userId = null;
    notifyListeners();
  }
}