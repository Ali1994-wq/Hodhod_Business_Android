import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _createAccount = false;
  bool _loginPasswordVisible = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _countryCode = '+249';

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirmPassword = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerConfirmPassword.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _submitLogin() {
    if (_loginEmail.text.trim().isEmpty || _loginPassword.text.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني وكلمة المرور.');
      return;
    }
    _showMessage('سيتم تنفيذ تسجيل الدخول عند ربط خدمة المصادقة.');
  }

  void _submitRegistration() {
    final email = _registerEmail.text.trim();
    final password = _registerPassword.text;
    final confirmation = _registerConfirmPassword.text;
    final phone = _phone.text.trim();

    if (email.isEmpty || password.isEmpty || confirmation.isEmpty || phone.isEmpty) {
      _showMessage('أكمل جميع بيانات إنشاء الحساب.');
      return;
    }
    if (password != confirmation) {
      _showMessage('كلمتا المرور غير متطابقتين.');
      return;
    }
    _showMessage('سيتم إرسال رسالة تأكيد إلى البريد الإلكتروني بعد ربط خدمة المصادقة.');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _createAccount
                      ? _buildRegister(context)
                      : _buildLogin(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Hodhod Messenger',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'مراسلة آمنة وبسيطة',
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildLogin(BuildContext context) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 34),
        TextField(
          controller: _loginEmail,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPassword,
          obscureText: !_loginPasswordVisible,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _loginPasswordVisible ? 'إخفاء كلمة المرور' : 'عرض كلمة المرور',
              onPressed: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
              icon: Icon(_loginPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _showMessage('استعادة كلمة المرور ستُرسل إلى بريدك الإلكتروني.'),
            child: const Text('هل نسيت كلمة المرور؟'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _submitLogin,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 22),
        const Divider(color: Colors.black12),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(() => _createAccount = true),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black38),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('إنشاء حساب'),
        ),
      ],
    );
  }

  Widget _buildRegister(BuildContext context) {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(
              tooltip: 'العودة لتسجيل الدخول',
              onPressed: () => setState(() => _createAccount = false),
              icon: const Icon(Icons.arrow_forward),
            ),
            const Expanded(
              child: Text(
                'إنشاء حساب جديد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _registerEmail,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _registerPassword,
          obscureText: !_passwordVisible,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _passwordVisible ? 'إخفاء كلمة المرور' : 'عرض كلمة المرور',
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _registerConfirmPassword,
          obscureText: !_confirmPasswordVisible,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'إعادة كتابة كلمة المرور',
            prefixIcon: const Icon(Icons.lock_reset_outlined),
            suffixIcon: IconButton(
              tooltip: _confirmPasswordVisible ? 'إخفاء كلمة المرور' : 'عرض كلمة المرور',
              onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              icon: Icon(_confirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 118,
              child: DropdownButtonFormField<String>(
                initialValue: _countryCode,
                decoration: const InputDecoration(labelText: 'رمز الدولة'),
                items: const [
                  DropdownMenuItem(value: '+249', child: Text('+249 السودان')),
                  DropdownMenuItem(value: '+20', child: Text('+20 مصر')),
                  DropdownMenuItem(value: '+966', child: Text('+966 السعودية')),
                  DropdownMenuItem(value: '+971', child: Text('+971 الإمارات')),
                  DropdownMenuItem(value: '+49', child: Text('+49 ألمانيا')),
                  DropdownMenuItem(value: '+44', child: Text('+44 بريطانيا')),
                  DropdownMenuItem(value: '+1', child: Text('+1 أمريكا/كندا')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _countryCode = value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'رقم الهاتف يُستخدم لربطك بجهات الاتصال والبحث عنك. التسجيل الأساسي يتم عبر البريد الإلكتروني.',
          style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _submitRegistration,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تأكيد إنشاء الحساب', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'بعد تأكيد التسجيل، سيتم إرسال رسالة تحقق إلى البريد الإلكتروني المسجل.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}
