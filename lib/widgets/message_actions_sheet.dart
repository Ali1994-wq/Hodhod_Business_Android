import 'package:flutter/material.dart';
import '../services/message_deletion_service.dart';

class MessageActionsSheet {
  static Future<void> show(
    BuildContext context, {
    required String messageId,
    bool canDeleteForEveryone = false,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.delete_sweep_outlined),
                title: Text('خيارات حذف الرسالة'),
              ),
              ListTile(
                leading: const Icon(Icons.person_remove_outlined),
                title: const Text('حذف لدي'),
                subtitle: const Text('تختفي الرسالة من جهازك فقط.'),
                onTap: () => Navigator.pop(context, 'me'),
              ),
              if (canDeleteForEveryone)
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined),
                  title: const Text('حذف لدى الجميع'),
                  subtitle: const Text('إزالة الرسالة من المحادثة للجميع.'),
                  onTap: () => Navigator.pop(context, 'everyone'),
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('إلغاء'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return;
    try {
      if (action == 'me') {
        await MessageDeletionService.deleteForMe(messageId);
      } else {
        await MessageDeletionService.deleteForEveryone(messageId);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'me'
                ? 'تم حذف الرسالة لديك.'
                : 'تم حذف الرسالة لدى الجميع.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف الرسالة: $e')),
      );
    }
  }
}
