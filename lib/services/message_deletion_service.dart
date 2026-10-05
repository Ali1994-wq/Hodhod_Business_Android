import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageDeletionService {
  static const _hiddenKey = 'hodhod_hidden_message_ids';

  static Future<void> deleteForMe(String messageId) async {
    final id = messageId.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_hiddenKey) ?? <String>[]).toSet()..add(id);
    await prefs.setStringList(_hiddenKey, ids.toList());
  }

  static Future<bool> isDeletedForMe(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_hiddenKey) ?? const <String>[]).contains(messageId);
  }

  static Future<void> deleteForEveryone(String messageId) async {
    final id = messageId.trim();
    if (id.isEmpty) {
      throw const PostgrestException(message: 'معرّف الرسالة غير صالح.');
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const PostgrestException(message: 'يجب تسجيل الدخول أولاً.');
    }

    await Supabase.instance.client
        .from('messages')
        .delete()
        .eq('id', id)
        .eq('sender_id', user.id);

    await deleteForMe(id);
  }
}
