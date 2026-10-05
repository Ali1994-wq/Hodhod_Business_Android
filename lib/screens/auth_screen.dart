import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool createAccount = false;
  bool loginPasswordVisible = false;
  bool passwordVisible = false;
  bool confirmVisible = false;
  bool busy = false;
  String countryCode = '+249';
  File? avatar;

  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();
  final regName = TextEditingController();
  final regEmail = TextEditingController();
  final regPassword = TextEditingController();
  final regConfirm = TextEditingController();
  final phone = TextEditingController();

  @override
  void dispose() {
    loginEmail.dispose(); loginPassword.dispose(); regName.dispose();
    regEmail.dispose(); regPassword.dispose(); regConfirm.dispose(); phone.dispose();
    super.dispose();
  }

  void message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> chooseAvatar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88, maxWidth: 1200, maxHeight: 1200);
    if (image != null) setState(() => avatar = File(image.path));
  }

  Future<void> submitLogin() async {
    final email = loginEmail.text.trim();
    final password = loginPassword.text;
    if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(email)) {
      message('أدخل بريداً إلكترونياً صحيحاً.'); return;
    }
    if (password.isEmpty) { message('أدخل كلمة المرور.'); return; }
    setState(() => busy = true);
    try {
      await AuthService.login(email, password);
      if (!mounted) return;
      message('تم تسجيل الدخول بنجاح.');
    } catch (e) {
      message(_error(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submitRegister() async {
    final name = regName.text.trim();
    final email = regEmail.text.trim().toLowerCase();
    final password = regPassword.text;
    final confirm = regConfirm.text;
    final rawPhone = phone.text.trim();

    if (name.isEmpty) { message('أدخل الاسم.'); return; }
    if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(email)) { message('أدخل بريداً إلكترونياً صحيحاً.'); return; }
    if (password.length < 6) { message('كلمة المرور يجب أن تكون 6 أحرف على الأقل.'); return; }
    if (password != confirm) { message('كلمتا المرور غير متطابقتين.'); return; }
    if (avatar == null) { message('اختر صورة البروفايل أولاً.'); return; }
    if (rawPhone.isNotEmpty && AuthService.normalizePhone(rawPhone, countryCode).length < 8) {
      message('رقم الهاتف غير صحيح.'); return;
    }

    setState(() => busy = true);
    try {
      final response = await AuthService.signUp(
        email: email,
        password: password,
        name: name,
        phone: rawPhone,
        countryCode: countryCode,
        avatar: avatar,
      );
      if (!mounted) return;
      if (response.session == null) {
        message('تم إنشاء الحساب. افتح بريدك الإلكتروني واضغط رابط التحقق، ثم سجّل الدخول لإكمال ملفك وصورة البروفايل.');
      } else {
        message('تم إنشاء الحساب وملفك الشخصي بنجاح.');
      }
    } catch (e) {
      message(_error(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> forgotPassword() async {
    final email = loginEmail.text.trim();
    if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(email)) {
      message('اكتب بريدك الإلكتروني أولاً.'); return;
    }
    setState(() => busy = true);
    try {
      await AuthService.resetPassword(email);
      message('تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني.');
    } catch (e) {
      message(_error(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _error(Object e) {
    final text = e.toString().replaceFirst('AuthException: ', '').replaceFirst('Exception: ', '');
    if (text.toLowerCase().contains('invalid login credentials')) return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    if (text.toLowerCase().contains('user already registered')) return 'هذا البريد مسجل مسبقاً.';
    if (text.toLowerCase().contains('email not confirmed')) return 'أكد بريدك الإلكتروني أولاً.';
    return text;
  }

  InputDecoration dec(String label, IconData icon, {Widget? suffix}) => InputDecoration(labelText: label, prefixIcon: Icon(icon), suffixIcon: suffix);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: createAccount ? registerView() : loginView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget header() => const Column(children: [
    Text('Hodhod Messenger', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w700)),
    SizedBox(height: 8),
    Text('مراسلة آمنة وبسيطة', style: TextStyle(color: Colors.black54, fontSize: 15)),
  ]);

  Widget loginView() => Column(children: [
    header(), const SizedBox(height: 34),
    TextField(controller: loginEmail, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: dec('البريد الإلكتروني', Icons.email_outlined)),
    const SizedBox(height: 16),
    TextField(controller: loginPassword, obscureText: !loginPasswordVisible, textDirection: TextDirection.ltr,
      decoration: dec('كلمة المرور', Icons.lock_outline, suffix: IconButton(
        onPressed: () => setState(() => loginPasswordVisible = !loginPasswordVisible),
        icon: Icon(loginPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      ))),
    Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: busy ? null : forgotPassword, child: const Text('هل نسيت كلمة المرور؟'))),
    const SizedBox(height: 8),
    SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : submitLogin, style: FilledButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: Text(busy ? 'جارٍ التنفيذ...' : 'تسجيل الدخول'))),
    const SizedBox(height: 22), const Divider(), const SizedBox(height: 12),
    OutlinedButton(onPressed: busy ? null : () => setState(() => createAccount = true), style: OutlinedButton.styleFrom(foregroundColor: Colors.black, minimumSize: const Size.fromHeight(52)), child: const Text('إنشاء حساب')),
  ]);

  Widget registerView() => Column(children: [
    header(), const SizedBox(height: 18),
    Row(children: [
      IconButton(onPressed: busy ? null : () => setState(() => createAccount = false), icon: const Icon(Icons.arrow_forward)),
      const Expanded(child: Text('إنشاء حساب جديد', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
      const SizedBox(width: 48),
    ]),
    const SizedBox(height: 12),
    GestureDetector(
      onTap: busy ? null : chooseAvatar,
      child: CircleAvatar(radius: 58, backgroundColor: Colors.black12, backgroundImage: avatar == null ? null : FileImage(avatar!), child: avatar == null ? const Icon(Icons.person, size: 52, color: Colors.black54) : null),
    ),
    const SizedBox(height: 10),
    OutlinedButton.icon(onPressed: busy ? null : chooseAvatar, icon: const Icon(Icons.photo_library_outlined), label: const Text('اختيار صورة البروفايل')),
    const SizedBox(height: 18),
    TextField(controller: regName, textDirection: TextDirection.rtl, decoration: dec('الاسم', Icons.person_outline)),
    const SizedBox(height: 16),
    TextField(controller: regEmail, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: dec('البريد الإلكتروني', Icons.email_outlined)),
    const SizedBox(height: 16),
    Row(children: [
      SizedBox(width: 118, child: DropdownButtonFormField<String>(
        value: countryCode, decoration: const InputDecoration(labelText: 'رمز الدولة'),
        items: const [
          DropdownMenuItem(value: '+249', child: Text('+249 السودان')),
          DropdownMenuItem(value: '+20', child: Text('+20 مصر')),
          DropdownMenuItem(value: '+966', child: Text('+966 السعودية')),
          DropdownMenuItem(value: '+971', child: Text('+971 الإمارات')),
          DropdownMenuItem(value: '+49', child: Text('+49 ألمانيا')),
          DropdownMenuItem(value: '+44', child: Text('+44 بريطانيا')),
          DropdownMenuItem(value: '+1', child: Text('+1 أمريكا/كندا')),
        ],
        onChanged: busy ? null : (v) { if (v != null) setState(() => countryCode = v); },
      )),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: dec('رقم الهاتف (اختياري)', Icons.phone_outlined))),
    ]),
    const SizedBox(height: 8),
    const Align(alignment: Alignment.centerRight, child: Text('رقم الهاتف للعثور عليك ضمن جهات الاتصال، وليس لتسجيل الدخول.', style: TextStyle(color: Colors.black54, fontSize: 12))),
    const SizedBox(height: 16),
    TextField(controller: regPassword, obscureText: !passwordVisible, textDirection: TextDirection.ltr, decoration: dec('كلمة المرور', Icons.lock_outline, suffix: IconButton(onPressed: () => setState(() => passwordVisible = !passwordVisible), icon: Icon(passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined)))),
    const SizedBox(height: 16),
    TextField(controller: regConfirm, obscureText: !confirmVisible, textDirection: TextDirection.ltr, decoration: dec('تأكيد كلمة المرور', Icons.lock_reset_outlined, suffix: IconButton(onPressed: () => setState(() => confirmVisible = !confirmVisible), icon: Icon(confirmVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined)))),
    const SizedBox(height: 24),
    SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : submitRegister, style: FilledButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: Text(busy ? 'جارٍ إنشاء الحساب...' : 'تأكيد إنشاء الحساب'))),
    const SizedBox(height: 16),
    const Text('سيتم إرسال رسالة تحقق إلى بريدك الإلكتروني. بعد التحقق وتسجيل الدخول، يُستكمل حفظ ملفك وصورة البروفايل.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
    const SizedBox(height: 12),
    TextButton(onPressed: busy ? null : () => setState(() => createAccount = false), child: const Text('العودة إلى تسجيل الدخول')),
  ]);
}
