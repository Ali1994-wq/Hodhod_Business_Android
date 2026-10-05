import 'package:flutter/material.dart';
import '../services/free_messages_service.dart';

class FreeMessagesScreen extends StatefulWidget {
  const FreeMessagesScreen({super.key});

  @override
  State<FreeMessagesScreen> createState() => _FreeMessagesScreenState();
}

class _FreeMessagesScreenState extends State<FreeMessagesScreen> {
  bool enabled = false;
  bool bluetooth = true;
  bool wifi = true;
  bool media = true;
  bool calls = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await Future.wait([
      FreeMessagesService.isEnabled(),
      FreeMessagesService.bluetoothEnabled(),
      FreeMessagesService.wifiEnabled(),
      FreeMessagesService.mediaEnabled(),
      FreeMessagesService.callsEnabled(),
    ]);
    if (!mounted) return;
    setState(() {
      enabled = values[0];
      bluetooth = values[1];
      wifi = values[2];
      media = values[3];
      calls = values[4];
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('الرسائل المجانية'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile.adaptive(
                  value: enabled,
                  activeColor: Colors.blue,
                  onChanged: (v) async {
                    setState(() => enabled = v);
                    await FreeMessagesService.setEnabled(v);
                  },
                  title: const Text('تفعيل الرسائل المجانية', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('استخدم الاتصال القريب بدلاً من الإنترنت عندما يتوفر جهاز هدهد قريب.'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('طرق الاتصال', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              _toggle('البلوتوث', 'اكتشاف الأجهزة القريبة والاتصال بها.', bluetooth, (v) async {
                setState(() => bluetooth = v);
                await FreeMessagesService.setBluetoothEnabled(v);
              }, Icons.bluetooth),
              _toggle('Wi‑Fi', 'اتصال محلي سريع لإرسال الرسائل والوسائط والمكالمات.', wifi, (v) async {
                setState(() => wifi = v);
                await FreeMessagesService.setWifiEnabled(v);
              }, Icons.wifi),
              const SizedBox(height: 12),
              const Text('الخدمات المجانية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              _toggle('الرسائل والوسائط', 'رسائل نصية وصور وفيديو وملفات عبر الاتصال المحلي.', media, (v) async {
                setState(() => media = v);
                await FreeMessagesService.setMediaEnabled(v);
              }, Icons.perm_media),
              _toggle('المكالمات الصوتية والمرئية', 'مكالمات جهاز إلى جهاز عند توفر مسار محلي مناسب.', calls, (v) async {
                setState(() => calls = v);
                await FreeMessagesService.setCallsEnabled(v);
              }, Icons.call),
              const SizedBox(height: 16),
              const Text(
                'لن تُخصم بيانات الهاتف عند استخدام مسار محلي مباشر. عند عدم توفر جهاز قريب، تعود المحادثة إلى اتصال الإنترنت المعتاد حسب إعدادات التطبيق.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      );

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) => Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SwitchListTile.adaptive(
          secondary: Icon(icon, color: Colors.blue.shade700),
          value: value,
          activeColor: Colors.blue,
          onChanged: enabled ? onChanged : null,
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      );
}
