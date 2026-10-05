import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../services/media_processing_service.dart';

class MediaEditorScreen extends StatelessWidget {
  const MediaEditorScreen({super.key});

  Future<void> _editImage(BuildContext context, ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (picked == null || !context.mounted) return;
    final optimized = await MediaProcessingService.optimizeImage(File(picked.path));
    if (!context.mounted) return;
    final bytes = await optimized.readAsBytes();
    if (!context.mounted) return;
    ImageEditor.setI18n({'Save': 'حفظ', 'Cancel': 'إلغاء', 'Remove': 'حذف'});
    final edited = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(builder: (_) => ImageEditor(image: bytes)),
    );
    if (!context.mounted || edited == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحسين الصورة وتحريرها وتجهيزها للإرسال.')),
    );
  }

  Future<void> _mirrorImage(BuildContext context, bool vertical) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (picked == null || !context.mounted) return;
    final source = img.decodeImage(await File(picked.path).readAsBytes());
    if (source == null || !context.mounted) return;
    final mirrored = vertical ? img.flipVertical(source) : img.flipHorizontal(source);
    final bytes = Uint8List.fromList(img.encodeJpg(mirrored, quality: 95));
    if (!context.mounted) return;
    final edited = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(builder: (_) => ImageEditor(image: bytes)),
    );
    if (!context.mounted || edited == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vertical ? 'تم تطبيق المرآة العمودية.' : 'تم تطبيق المرآة الأفقية.')),
    );
  }

  Future<void> _editVideo(BuildContext context) async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    final optimized = await MediaProcessingService.optimizeVideo(File(picked.path));
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoEditorScreen(file: optimized)),
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('محرر الصور والفيديو'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('تحرير وتحسين الوسائط', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'تتم المعالجة محلياً قبل الإرسال: تحسين الحجم والجودة، تنظيف بيانات EXIF الحساسة، ودعم تأثيرات المرآة للصور.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          _EditorTile(icon: Icons.camera_alt_outlined, title: 'التقاط وتحسين صورة', subtitle: 'الكاميرا ثم تحسين تلقائي قبل التحرير والإرسال.', onTap: () => _editImage(context, ImageSource.camera)),
          const SizedBox(height: 10),
          _EditorTile(icon: Icons.image_outlined, title: 'تحرير صورة', subtitle: 'فلاتر، قص، رسم، نص، رموز وملصقات.', onTap: () => _editImage(context, ImageSource.gallery)),
          const SizedBox(height: 10),
          _EditorTile(icon: Icons.flip_outlined, title: 'مرآة أفقية', subtitle: 'عكس الصورة يميناً ويساراً قبل الإرسال.', onTap: () => _mirrorImage(context, false)),
          const SizedBox(height: 10),
          _EditorTile(icon: Icons.flip_camera_android_outlined, title: 'مرآة عمودية', subtitle: 'عكس الصورة أعلى وأسفل.', onTap: () => _mirrorImage(context, true)),
          const SizedBox(height: 10),
          _EditorTile(icon: Icons.video_library_outlined, title: 'تحرير وتحسين فيديو', subtitle: 'تحسين وضغط ذكي مع H.265 عند توفره، ثم القص والمعاينة.', onTap: () => _editVideo(context)),
        ],
      ),
    ),
  );
}

class _EditorTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _EditorTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.blue.shade50,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Icon(icon, color: Colors.blue.shade700, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    ),
  );
}

class VideoEditorScreen extends StatefulWidget {
  final File file;
  const VideoEditorScreen({super.key, required this.file});
  @override State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0;
  double _endValue = 0;
  bool _loading = true;
  bool _saving = false;
  bool _playing = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      await _trimmer.loadVideo(videoFile: widget.file);
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر فتح الفيديو: ' + e.toString())));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (path) async {
        if (!mounted) return;
        if (path != null) {
          final optimized = await MediaProcessingService.optimizeVideo(File(path));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تنظيف وتحسين الفيديو وتجهيزه للإرسال: ' + optimized.path)),
          );
        }
        if (mounted) setState(() => _saving = false);
      },
    );
  }

  @override void dispose() { _trimmer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('تحرير الفيديو'),
        actions: [TextButton(onPressed: _loading || _saving ? null : _save, child: Text(_saving ? 'جارٍ التحسين' : 'حفظ'))],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          const SizedBox(height: 12),
          Expanded(child: VideoViewer(trimmer: _trimmer)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TrimViewer(
              trimmer: _trimmer,
              viewerHeight: 70,
              viewerWidth: MediaQuery.sizeOf(context).width - 24,
              maxVideoLength: const Duration(minutes: 10),
              onChangeStart: (value) => _startValue = value,
              onChangeEnd: (value) => _endValue = value,
              onChangePlaybackState: (value) { if (mounted) setState(() => _playing = value); },
            ),
          ),
          IconButton(
            color: Colors.white,
            iconSize: 56,
            onPressed: () async {
              final playing = await _trimmer.videoPlaybackControl(startValue: _startValue, endValue: _endValue);
              if (mounted) setState(() => _playing = playing);
            },
            icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle),
          ),
          const SizedBox(height: 18),
        ],
      ),
    ),
  );
}
