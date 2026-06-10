import 'package:flutter/material.dart';

class AuthGoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const AuthGoogleButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const _GoogleLogo(),
      label: const Text('Google'),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final strokeWidth = size.width * 0.25;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const segments = [
      (startAngle: -0.35, sweep: 1.92, color: Color(0xFF4285F4)),
      (startAngle: 1.57, sweep: 1.60, color: Color(0xFF34A853)),
      (startAngle: 3.17, sweep: 0.96, color: Color(0xFFFBBC05)),
      (startAngle: 4.13, sweep: 1.44, color: Color(0xFFEA4335)),
    ];

    for (final s in segments) {
      paint.color = s.color;
      canvas.drawArc(arcRect, s.startAngle, s.sweep, false, paint);
    }

    canvas.drawLine(
      center,
      Offset(size.width, center.dy),
      paint
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
