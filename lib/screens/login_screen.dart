import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_loading) return;
    setState(() => _loading = true);

    final user = await DatabaseHelper.instance.loginUser(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(username: user['username']),
        ),
        (_) => false,
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo / Icon
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const Center(
                    child: Text(
                      'Chào Bạn Nhé',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Đăng nhập để tiếp tục',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email field
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'your@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  const Text(
                    'Mật khẩu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white38,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => login(),
                  ),

                  const SizedBox(height: 36),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Đăng nhập'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Chưa có tài khoản? ',
                          style: TextStyle(color: Colors.white38),
                          children: [
                            TextSpan(
                              text: 'Đăng ký ngay',
                              style: TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
