import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'free_messages_screen.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    _section('الحساب وملف النشاط', ['الحساب وملف النشاط','معلومات النشاط التجاري','أيام وساعات العمل','نوع النشاط والموقع','الخدمات والكتالوج']),
    _section('الأمان والخصوصية', ['مفاتيح المرور وكلمة المرور','التحقق بخطوتين والتنبيهات الأمنية','اسم المستخدم والبريد والهاتف','الخصوصية والتحكم في المجموعات','الحظر والإبلاغ']),
    _section('الدردشات والإشعارات', ['المظهر والخط وحجم النص','خلفية المحادثات','نسخ المحادثات ونقلها','الإشعارات والنغمات']),
    _section('التخزين والبيانات', ['إدارة التخزين','توفير البيانات وجودة الوسائط','التنزيل التلقائي','جودة الصور والفيديو']),
    _section('التطبيق', ['لغة التطبيق','المساعدة','دعوة جهات الاتصال']),
    _freeMessagesEntry(context),
    const SizedBox(height: 4),
    OutlinedButton.icon(
      onPressed: () => _confirmDeleteAccount(context),
      icon: const Icon(Icons.delete_forever, color: Colors.red),
      label: const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
    ),
    const SizedBox(height: 12),
    OutlinedButton.icon(onPressed: AuthService.logout, icon: const Icon(Icons.logout, color: Colors.red), label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red))),
  ]);
  Widget _freeMessagesEntry(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Color(0xFFE8E8E8)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      leading: Icon(Icons.wifi_tethering, color: Colors.blue.shade700),
      title: const Text('الرسائل المجانية'),
      subtitle: const Text('Bluetooth وWi‑Fi للاتصال المحلي'),
      trailing: const Icon(Icons.chevron_left),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FreeMessagesScreen()),
      ),
    ),
  );

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الحساب'),
          content: const Text('سيتم حذف حسابك وبيانات ملفك من الخادم إذا كانت خدمة حذف الحساب مفعلة. هذا الإجراء لا يمكن التراجع عنه. هل تريد المتابعة؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف الحساب'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await AuthService.deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('AuthException: ', ''))),
      );
    }
  }

  Widget _section(String title, List<String> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(4,8,4,8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
    Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(14)),
      child: Column(children: items.map((x) => ListTile(leading: Icon(Icons.chevron_left, color: Colors.blue.shade700), title: Text(x), onTap: () {})).toList())),
    const SizedBox(height: 10),
  ]);
}
