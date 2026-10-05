import 'package:flutter/material.dart';
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});
  @override Widget build(BuildContext context) => Center(child: FilledButton.icon(
    onPressed: () => _create(context), icon: const Icon(Icons.group_add_outlined), label: const Text('إنشاء مجموعة')));
  void _create(BuildContext context) {
    final name = TextEditingController(), desc = TextEditingController();
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.white,
      builder: (c) => Padding(padding: EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(c).viewInsets.bottom+20),
        child: Directionality(textDirection: TextDirection.rtl, child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إنشاء مجموعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المجموعة *', border: OutlineInputBorder())), const SizedBox(height: 12),
          TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف *', border: OutlineInputBorder())), const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (name.text.trim().isEmpty || desc.text.trim().isEmpty) return; Navigator.pop(c); }, child: const Text('التالي'))),
        ]))));
  }
}
