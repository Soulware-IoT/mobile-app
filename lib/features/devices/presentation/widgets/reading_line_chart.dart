import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Hand-rolled single-series line chart with dashed warn/crit reference
/// lines — mirror of the web app's SVG chart, kept dependency-free.
class ReadingLineChart extends StatelessWidget {
  final List<double> values;
  final double? warn;
  final double? crit;

  const ReadingLineChart({
    super.key,
    required this.values,
    this.warn,
    this.crit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: CustomPaint(
        painter: _ReadingChartPainter(
          values: values,
          warn: warn,
          crit: crit,
          warnLabel: l10n.severityWarning,
          critLabel: l10n.severityCritical,
          lineColor: theme.colorScheme.primary,
          gridColor: theme.dividerColor.withValues(alpha: 0.3),
          labelColor: theme.colorScheme.onSurfaceVariant,
          // Same amber/red pairs used by the app's warning/critical pills.
          warnColor: const Color(0xFF7A5B00),
          critColor: const Color(0xFF9A2530),
        ),
      ),
    );
  }
}

class _ReadingChartPainter extends CustomPainter {
  final List<double> values;
  final double? warn;
  final double? crit;
  final String warnLabel;
  final String critLabel;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final Color warnColor;
  final Color critColor;

  const _ReadingChartPainter({
    required this.values,
    required this.warn,
    required this.crit,
    required this.warnLabel,
    required this.critLabel,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.warnColor,
    required this.critColor,
  });

  static const _labelStyleSize = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Y domain: readings plus both thresholds, padded 10% so the extremes
    // don't sit on the chart's edges.
    final domainValues = <double>[...values, ?warn, ?crit];
    var min = domainValues.isEmpty ? 0.0 : domainValues.reduce(math.min);
    var max = domainValues.isEmpty ? 1.0 : domainValues.reduce(math.max);
    if (min == max) {
      min -= 1;
      max += 1;
    }
    final pad = (max - min) * 0.10;
    min -= pad;
    max += pad;

    double y(double value) => size.height * (1 - (value - min) / (max - min));

    // Light horizontal gridlines.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final gy = size.height * i / 3;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    // Min/max labels on the left edge.
    _label(canvas, _format(max), Offset(2, 2), labelColor);
    _label(
      canvas,
      _format(min),
      Offset(2, size.height - _labelStyleSize - 4),
      labelColor,
    );

    // Threshold dashed lines with right-aligned name labels (Warning/Critical).
    if (warn != null) _dashedLine(canvas, size, y(warn!), warnColor, warnLabel);
    if (crit != null) _dashedLine(canvas, size, y(crit!), critColor, critLabel);

    // Series polyline.
    if (values.length >= 2) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1);
        final point = Offset(x, y(values[i]));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Latest-value dot.
    if (values.isNotEmpty) {
      canvas.drawCircle(
        Offset(size.width, y(values.last)),
        3,
        Paint()..color = lineColor,
      );
    }
  }

  void _dashedLine(
    Canvas canvas,
    Size size,
    double dy,
    Color color,
    String label,
  ) {
    if (dy < 0 || dy > size.height) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, dy),
        Offset(math.min(x + dash, size.width), dy),
        paint,
      );
      x += dash + gap;
    }

    final painter = _textPainter(label, color);
    painter.paint(
      canvas,
      Offset(size.width - painter.width - 2, dy - painter.height - 2),
    );
  }

  void _label(Canvas canvas, String text, Offset offset, Color color) {
    _textPainter(text, color).paint(canvas, offset);
  }

  TextPainter _textPainter(String text, Color color) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: _labelStyleSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
  }

  String _format(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);

  @override
  bool shouldRepaint(covariant _ReadingChartPainter oldDelegate) =>
      oldDelegate.values.length != values.length ||
      (values.isNotEmpty &&
          oldDelegate.values.isNotEmpty &&
          oldDelegate.values.last != values.last) ||
      oldDelegate.warn != warn ||
      oldDelegate.crit != crit;
}
