import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/translations.dart';

class DeveloperCredits extends StatelessWidget {
  final Color? textColor;
  final Color? subtextColor;

  const DeveloperCredits({
    super.key,
    this.textColor,
    this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveSubtextColor =
        subtextColor ?? Colors.white.withValues(alpha: 0.85);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.isArabic ? 'المطور:' : 'Developer:',
              style: GoogleFonts.cairo(
                color: effectiveTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/orf.jpg',
                height: 19,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '™ORFLYS',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: effectiveTextColor,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'SOFTWARE STUDIO',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor.withValues(alpha: 0.9),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'ORFLYS 2026 ©',
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: effectiveSubtextColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
