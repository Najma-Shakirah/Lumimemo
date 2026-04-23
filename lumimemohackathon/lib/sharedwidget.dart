import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'apptheme.dart';

// ── App Logo / Brand ─────────────────────────────────────────────────────────
class MemoryBridgeLogo extends StatelessWidget {
  final double size;
  const MemoryBridgeLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(Icons.auto_stories_rounded,
              color: AppTheme.background, size: size * 0.54),
        ),
        const SizedBox(height: 12),
        Text(
          'Lumimemo',
          style: GoogleFonts.dmSerifDisplay(
            color: AppTheme.textPrimary,
            fontSize: 26,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Preserve what matters most',
          style: GoogleFonts.dmSans(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.background,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.background,
                ),
              ),
      ),
    );
  }
}

// ── Custom Text Field ─────────────────────────────────────────────────────────
class MBTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffix;

  const MBTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

// ── Section Divider with text ─────────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.surfaceAlt, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: GoogleFonts.dmSans(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ),
        const Expanded(child: Divider(color: AppTheme.surfaceAlt, thickness: 1)),
      ],
    );
  }
}