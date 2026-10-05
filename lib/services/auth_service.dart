import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static String normalizePhone(String raw, String countryCode) {
    var value = raw.trim().replaceAll(RegExp(r'[\\s\\-()]+'), '');
    if (value.startsWith('00')) value = '+' + value.substring(2);
    if (value.startsWith('+')) return '+' + value.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return '';
    if (countryCode == '+249') {
      if (value.startsWith('249')) return '+' + value;
      if (value.startsWith('09')) value = value.substring(1);
      if (value.startsWith('9')) return '+249' + value;
    }
    return countryCode + value;
  }

  static String usernameFor(String email, String userId) {
    var local = email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    local = local.replaceAll(RegExp(r'_+'), '_');
    if (local.isEmpty) local = 'user';
    final suffix = userId.length >= 6 ? userId.substring(0, 6) : userId;
    return local + '_' + suffix;
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String countryCode,
    required File? avatar,
  }) async {
    final response = await _client.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user == null) throw const AuthException('تعذر إنشاء حساب المستخدم.');
    if (avatar != null) {
      await _savePendingProfile(
        userId: user.id,
        name: name,
        email: email,
        phone: phone.isEmpty ? '' : normalizePhone(phone, countryCode),
        avatar: avatar,
      );
    }
    if (response.session != null) await finalizeProfile(user.id);
    return response;
  }

  static Future<void> finalizeProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingId = prefs.getString('pending_profile_user_id');
    if (pendingId != null && pendingId != userId) return;
    final name = prefs.getString('pending_profile_name');
    final email = prefs.getString('pending_profile_email');
    final phone = prefs.getString('pending_profile_phone');
    final avatarPath = prefs.getString('pending_profile_avatar');
    if (name == null || email == null) return;

    String? avatarUrl;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final file = File(avatarPath);
      if (await file.exists()) {
        final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
        final safeExt = ext.isEmpty ? 'jpg' : ext;
        final objectPath = 'avatars/' + userId + '.' + safeExt;
        final bytes = await file.readAsBytes();
        final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';
        await _client.storage.from('avatars').uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
        avatarUrl = _client.storage.from('avatars').getPublicUrl(objectPath);
      }
    }

    await _client.rpc('hodhod_create_my_profile', params: {
      'p_display_name': name,
      'p_username': usernameFor(email, userId),
      'p_phone': phone == null || phone.isEmpty ? null : phone,
      'p_phone_normalized': phone == null || phone.isEmpty ? null : phone,
      'p_avatar_url': avatarUrl,
    });

    if (avatarPath != null) {
      try { await File(avatarPath).delete(); } catch (_) {}
    }
    await prefs.remove('pending_profile_user_id');
    await prefs.remove('pending_profile_name');
    await prefs.remove('pending_profile_email');
    await prefs.remove('pending_profile_phone');
    await prefs.remove('pending_profile_avatar');
  }

  static Future<void> _savePendingProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required File avatar,
  }) async {
    final dir = Directory(avatar.parent.path + '/hodhod_pending');
    if (!await dir.exists()) await dir.create(recursive: true);
    final target = File(dir.path + '/avatar_' + userId + p.extension(avatar.path));
    await avatar.copy(target.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_profile_user_id', userId);
    await prefs.setString('pending_profile_name', name);
    await prefs.setString('pending_profile_email', email);
    await prefs.setString('pending_profile_phone', phone);
    await prefs.setString('pending_profile_avatar', target.path);
  }

  static Future<void> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) throw const AuthException('تعذر تسجيل الدخول.');
    await finalizeProfile(user.id);
  }

  static Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  static Future<void> logout() => _client.auth.signOut();

  static Future<void> deleteAccount() async {
    try {
      await _client.rpc('hodhod_delete_my_account');
    } on PostgrestException catch (e) {
      throw AuthException('تعذر حذف الحساب من الخادم: ' + e.message);
    }
    await _client.auth.signOut();
  }
}
