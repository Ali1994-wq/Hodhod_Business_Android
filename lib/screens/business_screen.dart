import 'package:flutter/material.dart';
class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});
  @override Widget build(BuildContext context) {
    const items = [
      ('المنتجات والخدمات', Icons.inventory_2_outlined), ('الإعلانات والترويج', Icons.campaign_outlined),
      ('تنظيم محادثات العملاء', Icons.forum_outlined), ('ملف النشاط التجاري', Icons.storefront_outlined),
      ('الردود التلقائية', Icons.smart_toy_outlined), ('الردود السريعة', Icons.flash_on_outlined),
      ('ربط الحسابات الاجتماعية', Icons.link_outlined), ('مركز المساعدة', Icons.help_outline),
    ];
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) { final x=items[i]; return Card(color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(14)),
        child: ListTile(leading: Icon(x.$2, color: Colors.blue.shade700), title: Text(x.$1), trailing: const Icon(Icons.chevron_left), onTap: () {})); });
  }
}
