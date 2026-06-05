import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

enum KineticButtonStyle { primary, secondary }

class KineticButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final KineticButtonStyle style;

  const KineticButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style = KineticButtonStyle.primary,
  }) : super(key: key);

  @override
  State<KineticButton> createState() => _KineticButtonState();
}

class _KineticButtonState extends State<KineticButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.style == KineticButtonStyle.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isPrimary ? AppColors.primary : Colors.transparent,
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          boxShadow: _isHovered && isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Text(
                  widget.text.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.black : Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
