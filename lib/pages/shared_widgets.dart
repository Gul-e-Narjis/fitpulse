// ── Shared widgets used across multiple screens ───────────────────────────────
// Import this file wherever TealField is needed.

import 'package:flutter/material.dart';
import '../theme/fp_theme.dart';
import '../theme/neon.dart';
import 'app_colors.dart'; // AppColors

/// Neon glass text field with a cyan glow while focused.
/// Used in LoginScreen and SignUpScreen.
class TealField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const TealField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<TealField> createState() => _TealFieldState();
}

class _TealFieldState extends State<TealField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c, width: w),
  );

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: Neon.cyan.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: -4,
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        cursorColor: Neon.cyan,
        style: FpText.body(color: Colors.white, size: 15),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: FpText.body(color: FpColors.muted, size: 14),
          floatingLabelStyle: Neon.hud(size: 11, spacing: 1.4),
          prefixIcon: Icon(
            widget.icon,
            color: focused ? Neon.cyan : AppColors.textGrey,
            size: 20,
          ),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: Colors.white.withValues(alpha: focused ? 0.07 : 0.04),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: FpText.body(color: Neon.danger, size: 12),
          border: _border(Colors.white.withValues(alpha: 0.14)),
          enabledBorder: _border(Colors.white.withValues(alpha: 0.14)),
          focusedBorder: _border(Neon.cyan, 1.6),
          errorBorder: _border(Neon.danger.withValues(alpha: 0.8)),
          focusedErrorBorder: _border(Neon.danger, 1.6),
        ),
      ),
    );
  }
}

/// Placeholder shown on web for features that need phone hardware
/// (step sensor, local notifications).
class MobileOnlyNotice extends StatelessWidget {
  final IconData icon;
  final String feature;

  const MobileOnlyNotice({
    super.key,
    required this.icon,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.sageGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available on mobile app',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$feature needs your phone and isn\'t supported in the browser.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
