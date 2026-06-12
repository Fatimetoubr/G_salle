import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class Api {
  static final Api _i = Api._();
  factory Api() => _i;
  Api._();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json; charset=UTF-8'};
    if (auth) {
      final p = await SharedPreferences.getInstance();
      final t = p.getString(AppConstants.tokenKey);
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Future<dynamic> _req(String method, String path,
      {Map<String, dynamic>? body, bool auth = true}) async {

    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final hdrs = await _headers(auth: auth);

    print("URL: $uri");

    http.Response res;

    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: hdrs);
          break;
        case 'POST':
          res = await http.post(uri, headers: hdrs, body: jsonEncode(body));
          break;
        case 'PUT':
          res = await http.put(uri, headers: hdrs, body: jsonEncode(body));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: hdrs);
          break;
        default:
          throw ApiException('Méthode inconnue');
      }
    } catch (e) {
      print("❌ NETWORK ERROR: $e");
      throw ApiException("Impossible de contacter le serveur");
    }

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      decoded = res.body;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final msg = decoded is Map
        ? (decoded['message'] ?? 'Erreur serveur')
        : 'Erreur serveur';

    throw ApiException(msg.toString());
  }

  // ================= AUTH =================

  Future<Map<String, dynamic>> register(
      String name, String email, String pw, String confirm) async {
    final res = await _req('POST', '/auth/register', auth: false, body: {
      'fullname': name,
      'email': email,
      'password': pw,
      'confirmPassword': confirm
    });
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String pw) async {
    final res = await _req('POST', '/auth/login',
        auth: false, body: {'email': email, 'password': pw});
    return res as Map<String, dynamic>;
  }

  // ================= SALLES =================

  Future<List<SalleModel>> getSalles() async {
    final d = await _req('GET', '/salles');
    return (d as List).map((e) => SalleModel.fromJson(e)).toList();
  }

  Future<DisponibiliteModel> getDisponibilite(int id, String date) async {
    final d = await _req('GET', '/salles/$id/disponibilite?date=$date');
    return DisponibiliteModel.fromJson(d);
  }

  Future<SalleModel> createSalle(Map<String, dynamic> body) async {
    final d = await _req('POST', '/admin/salles', body: body);
    return SalleModel.fromJson(d);
  }

  Future<SalleModel> updateSalle(int id, Map<String, dynamic> body) async {
    final d = await _req('PUT', '/admin/salles/$id', body: body);
    return SalleModel.fromJson(d);
  }

  Future<void> deleteSalle(int id) async {
    await _req('DELETE', '/admin/salles/$id');
  }

  // ================= RESERVATIONS =================

  Future<ReservationModel> createReservation(
      int salleId, String date, String debut, String fin) async {
    final d = await _req('POST', '/reservations', body: {
      'salleId': salleId,
      'date': date,
      'heureDebut': debut,
      'heureFin': fin
    });
    return ReservationModel.fromJson(d);
  }

  Future<List<ReservationModel>> getMyReservations() async {
    final d = await _req('GET', '/reservations/mes-reservations');
    return (d as List)
        .map((e) => ReservationModel.fromJson(e))
        .toList();
  }

  Future<List<ReservationModel>> getAllReservations() async {
    final d = await _req('GET', '/admin/reservations');
    return (d as List)
        .map((e) => ReservationModel.fromJson(e))
        .toList();
  }

  Future<void> acceptReservation(int id) async {
    await _req('PUT', '/admin/reservations/$id/accepter');
  }

  Future<void> refuseReservation(int id) async {
    await _req('PUT', '/admin/reservations/$id/refuser');
  }

  // ================= NOTIFICATIONS =================

  Future<List<NotifModel>> getNotifications() async {
    final d = await _req('GET', '/notifications');
    return (d as List)
        .map((e) => NotifModel.fromJson(e))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final d = await _req('GET', '/notifications/unread-count');
    return (d['unreadCount'] ?? 0);
  }

  // ================= USER =================

  Future<UserModel> getMyProfile() async {
    final d = await _req('GET', '/user/me');
    return UserModel.fromJson(d);
  }

  Future<List<UserModel>> getAllUsers() async {
    final d = await _req('GET', '/admin/users');
    return (d as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> body) async {
    final d = await _req('PUT', '/admin/users/$id', body: body);
    return UserModel.fromJson(d);
  }

  Future<void> deactivateUser(int id) async {
    await _req('PUT', '/admin/users/$id/desactiver');
  }

  // ✅ FIX IMPORTANT
  Future<void> deleteUser(int id) async {
    await _req('DELETE', '/admin/users/$id');
  }
}