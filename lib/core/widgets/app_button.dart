import 'package:flutter/material.dart';
import '../theme/cooli_theme.dart';

enum AppButtonVariant { primary, accent, secondary, danger, success }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = CooliPartnerTheme.primaryBlue;
        fg = Colors.white;
        break;
      case AppButtonVariant.accent:
        bg = CooliPartnerTheme.accentAmber;
        fg = const Color(0xFF0F172A);
        break;
      case AppButtonVariant.secondary:
        bg = Colors.white;
        fg = const Color(0xFF0F172A);
        border = const BorderSide(color: Color(0xFFCBD5E1));
        break;
      case AppButtonVariant.danger:
        bg = CooliPartnerTheme.emergencyRed;
        fg = Colors.white;
        break;
      case AppButtonVariant.success:
        bg = CooliPartnerTheme.successGreen;
        fg = Colors.white;
        break;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
