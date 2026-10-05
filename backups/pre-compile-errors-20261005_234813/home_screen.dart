import 'package:flutter/material.dart';
import 'business_screen.dart';
import 'calls_screen.dart';
import 'chats_screen.dart';
import 'groups_screen.dart';
import 'media_editor_screen.dart';
import 'settings_screen.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int top = 0;
  int bottom = -1;

  Widget get page {
    if (bottom == 0) return const CallsScreen();
    if (bottom == 1) return const StatusScreen();
    switch (top) {
      case 1: return const GroupsScreen();
      case 2: return const BusinessScreen();
      case 3: return const SettingsScreen();
      default: return const ChatsScreen();
    }
  }

  void selectTop(int i) => setState(() { top = i; bottom = -1; });
  void selectBottom(int i) => setState(() => bottom = i);

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0,
        titleSpacing: 12,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: Colors.blue.shade200)),
            child: Icon(Icons.flutter_dash, color: Colors.blue.shade700)),
          const SizedBox(width: 10),
          const Text('Hodhod', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w700, fontFamily: 'serif')),
        ]),
        actions: [
          IconButton(onPressed: () => _chatOptions(context), icon: Icon(Icons.more_horiz, color: Colors.blue.shade700)),
          IconButton(onPressed: () => showSearch(context: context, delegate: _SearchDelegate()), icon: Icon(Icons.search, color: Colors.blue.shade700)),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        _TopNav(selected: top, bottomActive: bottom >= 0, onSelected: selectTop),
        Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: KeyedSubtree(key: ValueKey('$top-$bottom'), child: page))),
      ]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.white, indicatorColor: Colors.blue.shade50,
        selectedIndex: bottom < 0 ? 0 : bottom, onDestinationSelected: selectBottom,
        destinations: [
          NavigationDestination(icon: Icon(Icons.call_outlined, color: Colors.blue.shade700), selectedIcon: Icon(Icons.call, color: Colors.blue.shade700), label: 'المكالمات'),
          NavigationDestination(icon: Icon(Icons.circle_outlined, color: Colors.blue.shade700), selectedIcon: Icon(Icons.circle, color: Colors.blue.shade700), label: 'الحالات'),
        ],
      ),
    ),
  );

  void _chatOptions(BuildContext context) => showModalBottomSheet<void>(
    context: context, backgroundColor: Colors.white,
    builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.mark_email_unread_outlined, color: Colors.blue.shade700), title: const Text('المحادثات غير المقروءة'), onTap: () => Navigator.pop(context)),
      ListTile(leading: Icon(Icons.archive_outlined, color: Colors.blue.shade700), title: const Text('المحادثات المؤرشفة'), onTap: () => Navigator.pop(context)),
      ListTile(leading: Icon(Icons.movie_edit_outlined, color: Colors.blue.shade700), title: const Text('محرر الصور والفيديو'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaEditorScreen())); }),
      ListTile(leading: Icon(Icons.settings_outlined, color: Colors.blue.shade700), title: const Text('إعدادات الدردشة'), onTap: () { Navigator.pop(context); selectTop(3); }),
    ])),
  );
}

class _TopNav extends StatelessWidget {
  final int selected; final bool bottomActive; final ValueChanged<int> onSelected;
  const _TopNav({required this.selected, required this.bottomActive, required this.onSelected});
  @override Widget build(BuildContext context) {
    const labels = ['الدردشات', 'المجموعات', 'الاعمال', 'الاعدادات'];
    const icons = [Icons.chat_bubble_outline, Icons.groups_outlined, Icons.storefront_outlined, Icons.settings_outlined];
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8)))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(children: List.generate(labels.length, (i) {
          final active = !bottomActive && selected == i;
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: InkWell(
            borderRadius: BorderRadius.circular(12), onTap: () => onSelected(i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(color: active ? Colors.blue.shade50 : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [Icon(icons[i], size: 19, color: Colors.blue.shade700), const SizedBox(width: 6), Text(labels[i], style: TextStyle(color: Colors.black, fontWeight: active ? FontWeight.w700 : FontWeight.w500))]),
            ),
          ));
        })),
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext context) => const Center(child: Text('سيتم ربط البحث الحقيقي بالأشخاص والمجموعات والرسائل.'));
  @override Widget buildSuggestions(BuildContext context) => const Center(child: Text('ابحث عن شخص أو مجموعة أو رسالة.'));
}
