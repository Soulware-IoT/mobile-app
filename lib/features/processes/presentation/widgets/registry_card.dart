import 'package:flutter/material.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_registry.dart';

/// One "recent log": the filing timestamp plus the registry's field values,
/// labeled through the owning format's field definitions.
class RegistryCard extends StatelessWidget {
  final ControlRegistry registry;

  /// The format the registry was filed against; resolves field keys to labels
  /// and keeps values in display order.
  final ControlFormat format;

  const RegistryCard({super.key, required this.registry, required this.format});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _orderedEntries();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _date(registry.createdAt),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                Icon(
                  Icons.fact_check_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        e.$1,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      e.$2,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// (label, rendered value) pairs following the format's display order;
  /// values whose key no longer exists in the format fall to the end.
  List<(String, String)> _orderedEntries() {
    final byKey = {for (final f in format.orderedFields) f.key: f};
    final known = <(String, String)>[];
    final unknown = <(String, String)>[];

    for (final field in format.orderedFields) {
      if (registry.data.containsKey(field.key)) {
        known.add((field.label, _render(registry.data[field.key])));
      }
    }
    for (final entry in registry.data.entries) {
      if (!byKey.containsKey(entry.key)) {
        unknown.add((entry.key, _render(entry.value)));
      }
    }
    return [...known, ...unknown];
  }

  String _render(Object? value) {
    if (value == null) return '—';
    if (value is bool) return value ? '✓' : '✕';
    return '$value';
  }

  String _date(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}
