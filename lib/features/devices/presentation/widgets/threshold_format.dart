import 'package:cocina360/features/devices/domain/model/thresholds.dart';

/// Formatting helpers for [Thresholds], shared by the card and the detail page.
class ThresholdFormat {
  const ThresholdFormat._();

  /// Compact one-line summary, e.g. "Temp 8°/12°C · Gas 100/200 ppm".
  /// Empty parts are dropped; returns [emptyLabel] (already localized by the
  /// caller) when there are no thresholds.
  static String summary(Thresholds t, {required String emptyLabel}) {
    if (t.isEmpty) return emptyLabel;

    final parts = <String>[];
    final temp = _range(t.warnTemperatureC, t.critTemperatureC);
    if (temp != null) parts.add('Temp $temp°C');
    final gas = _range(t.warnGasPpm, t.critGasPpm);
    if (gas != null) parts.add('Gas $gas ppm');
    return parts.join(' · ');
  }

  /// "warn/crit" with whichever bound is present.
  static String? _range(num? warn, num? crit) {
    if (warn == null && crit == null) return null;
    final w = warn == null ? '—' : _num(warn);
    final c = crit == null ? '—' : _num(crit);
    return '$w/$c';
  }

  static String _num(num n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}
