import 'package:flutter/material.dart';
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  @override Widget build(BuildContext context) => const Center(
    child: Padding(padding: EdgeInsets.all(28), child: Text(
      'لا توجد محادثات بعد.\n\nسيتم ربط هذه الصفحة بسجل المحادثات الحقيقي مع الاسم والصورة وآخر رسالة والوقت وحالة القراءة.',
      textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.6))),
  );
}
