import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final appState = context.read<AppState>();
    try {
      final user = await AuthService.signIn(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      await appState.loadUser(user);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } on AuthFailure catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Could not load your data. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your account email and we'll send you a reset link.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (email == null) return;
    if (!email.contains('@')) {
      _showSnack('Enter a valid email address.', isError: true);
      return;
    }
    try {
      await AuthService.sendPasswordReset(email);
      _showSnack(
        'If an account exists for $email, a reset link has been sent.',
      );
    } on AuthFailure catch (e) {
      _showSnack(e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkTeal,
      body: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top teal section ──────────────────
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 36,
                              color: AppColors.sageGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue your journey',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── White bottom card ─────────────────
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email
                            TealField(
                              controller: _emailCtrl,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || !v.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TealField(
                              controller: _passCtrl,
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textGrey,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => v == null || v.length < 6
                                  ? 'Min 6 characters'
                                  : null,
                            ),

                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.sageGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign In button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sageGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: AppColors.border),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: AppColors.border),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Sign Up redirect
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/signup'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.sageGreen,
                                  side: const BorderSide(
                                    color: AppColors.sageGreen,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable teal text field ──────────────────────────────────────────────────
