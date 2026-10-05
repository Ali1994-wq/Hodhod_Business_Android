import 'package:flutter/material.dart';

void main() => runApp(const HodhodBusinessApp());

class HodhodBusinessApp extends StatelessWidget {
  const HodhodBusinessApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hodhod Business',
    theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F2D4D))),
    home: const BusinessShell(),
  );
}

class BusinessShell extends StatefulWidget {
  const BusinessShell({super.key});
  @override State<BusinessShell> createState() => _BusinessShellState();
}
class _BusinessShellState extends State<BusinessShell> {
  int index = 0;
  final pages = const [DashboardPage(), OrdersPage(), ProductsPage(), CustomersPage(), MorePage()];
  @override Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Hodhod أعمال', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))]),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'), NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'الطلبات'), NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'المنتجات'), NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'العملاء'), NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'المزيد')]),
    ),
  );
}

class DashboardPage extends StatelessWidget { const DashboardPage({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [const Text('ملخص النشاط', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 14), Row(children: [StatCard('المبيعات', '0 ج.س', Icons.trending_up_rounded), const SizedBox(width: 10), StatCard('الطلبات', '0', Icons.shopping_bag_outlined)]), const SizedBox(height: 10), Row(children: [StatCard('العملاء', '0', Icons.people_outline_rounded), const SizedBox(width: 10), StatCard('الرصيد', '0 ج.س', Icons.account_balance_wallet_outlined)]), const SizedBox(height: 20), SectionCard(title: 'إجراءات سريعة', children: [ActionTile(Icons.add_box_outlined, 'إضافة منتج', 'إدارة كتالوج المنتجات'), ActionTile(Icons.receipt_long_outlined, 'عرض الطلبات', 'متابعة الطلبات الحالية'), ActionTile(Icons.bar_chart_rounded, 'التقارير', 'مؤشرات الأداء والمبيعات')]), const SizedBox(height: 16), SectionCard(title: 'حالة الحساب', children: [ListTile(leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)), title: const Text('متجر جديد'), subtitle: const Text('أكمل بيانات النشاط التجاري للبدء'), trailing: FilledButton(onPressed: () {}, child: const Text('إعداد')))])]); }
class OrdersPage extends StatelessWidget { const OrdersPage({super.key}); @override Widget build(BuildContext context) => const EmptyPage(icon: Icons.receipt_long_rounded, title: 'الطلبات', text: 'ستظهر هنا الطلبات الجديدة وحالاتها.'); }
class ProductsPage extends StatelessWidget { const ProductsPage({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المنتجات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('منتج جديد'))]), const SizedBox(height: 20), const EmptyPage(icon: Icons.inventory_2_rounded, title: 'لا توجد منتجات', text: 'أضف منتجاتك لبناء الكتالوج التجاري.')]); }
class CustomersPage extends StatelessWidget { const CustomersPage({super.key}); @override Widget build(BuildContext context) => const EmptyPage(icon: Icons.people_rounded, title: 'العملاء', text: 'ستتم إدارة العملاء والمحادثات التجارية من هنا.'); }
class MorePage extends StatelessWidget { const MorePage({super.key}); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [Text('المزيد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), SizedBox(height: 12), Card(child: Column(children: [ListTile(leading: Icon(Icons.account_balance_wallet_outlined), title: Text('المحفظة'), subtitle: Text('الرصيد والمعاملات')), ListTile(leading: Icon(Icons.bar_chart_rounded), title: Text('التقارير'), subtitle: Text('تحليل أداء النشاط')), ListTile(leading: Icon(Icons.settings_outlined), title: Text('الإعدادات'), subtitle: Text('إعدادات النشاط والحساب'))]))]); }
class StatCard extends StatelessWidget { final String title,value; final IconData icon; const StatCard(this.title,this.value,this.icon,{super.key}); @override Widget build(BuildContext c)=>Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 26), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.black54)), Text(value, style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w800))])))); }
class SectionCard extends StatelessWidget { final String title; final List<Widget> children; const SectionCard({required this.title,required this.children,super.key}); @override Widget build(BuildContext c)=>Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800,fontSize: 17))), ...children]))); }
class ActionTile extends StatelessWidget { final IconData icon; final String title,sub; const ActionTile(this.icon,this.title,this.sub,{super.key}); @override Widget build(BuildContext c)=>ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title), subtitle: Text(sub), trailing: const Icon(Icons.chevron_left)); }
class EmptyPage extends StatelessWidget { final IconData icon; final String title,text; const EmptyPage({required this.icon,required this.title,required this.text,super.key}); @override Widget build(BuildContext c)=>Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon,size:64,color: const Color(0xFF0F2D4D)), const SizedBox(height:16), Text(title,style: const TextStyle(fontSize:22,fontWeight: FontWeight.w800)), const SizedBox(height:8), Text(text,textAlign: TextAlign.center,style: const TextStyle(color: Colors.black54))]))); }
