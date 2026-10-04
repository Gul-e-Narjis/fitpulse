import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/fp_theme.dart';
import '../theme/neon.dart';
import 'shared_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _loading = false;
  bool _agree = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _clearError([String _ = '']) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      setState(() => _error = 'Please agree to the Terms & Conditions.');
      return;
    }
    setState(() => _loading = true);
    final appState = context.read<AppState>();
    try {
      final user = await AuthService.signUp(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      // Pass the name explicitly so users/{uid} is created with it
      await appState.loadUser(user, name: _nameCtrl.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (r) => false);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              'Account created, but saving your profile failed. Try signing in.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeonAuthScaffold(
      photo: 'assets/images/slide2.jpg',
      title: 'Join FitPulse',
      subtitle: 'Create your free account',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeonErrorBanner(message: _error),
              TealField(
                controller: _nameCtrl,
                label: 'Full name',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                onChanged: _clearError,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),
              TealField(
                controller: _emailCtrl,
                label: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: _clearError,
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 14),
              TealField(
                controller: _passCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                onChanged: _clearError,
                onSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: FpColors.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 10),

              // Terms checkbox
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() => _agree = !_agree);
                  _clearError();
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: Neon.cyan,
                      checkColor: Neon.navy,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) {
                        setState(() => _agree = v ?? false);
                        _clearError();
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: FpText.body(
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: FpText.body(
                                color: Neon.cyan,
                                size: 13,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              NeonGradientButton(
                label: 'Create Account',
                loading: _loading,
                onTap: _submit,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: FpText.body(
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      'Sign in',
                      style: FpText.h3(color: Neon.lime).copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
