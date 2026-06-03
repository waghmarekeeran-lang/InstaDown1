import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InstaDownLogo extends StatelessWidget {
  final double fontSize;
  const InstaDownLogo({super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        children: [
          const TextSpan(
              text: 'INSTA ', style: TextStyle(color: AppColors.primary)),
          const TextSpan(
              text: 'D', style: TextStyle(color: AppColors.primary)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: fontSize * 0.72,
              height: fontSize * 0.85,
              child: CustomPaint(painter: _TrianglePainter()),
            ),
          ),
          const TextSpan(
              text: 'WN', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()
        ..color = AppColors.yellowAccent
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class PeachBackground extends StatelessWidget {
  final Widget child;
  const PeachBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}
