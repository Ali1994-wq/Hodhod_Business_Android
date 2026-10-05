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
    const SizedBox(height: 12),
    OutlinedButton.icon(onPressed: AuthService.logout, icon: const Icon(Icons.logout, color: Colors.red), label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red))),
  ]);
  Widget _section(String title, List<String> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(4,8,4,8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
    Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(14)),
      child: Column(children: items.map((x) => ListTile(leading: Icon(Icons.chevron_left, color: Colors.blue.shade700), title: Text(x), onTap: () {})).toList())),
    const SizedBox(height: 10),
  ]);
}
