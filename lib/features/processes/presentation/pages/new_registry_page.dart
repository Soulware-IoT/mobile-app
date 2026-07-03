import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/presentation/cubit/new_registry_cubit.dart';
import 'package:cocina360/features/processes/presentation/cubit/new_registry_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Files a new registry for [format]: renders one input per format field and
/// validates each against the field's type and validation rules (required,
/// text length/pattern, numeric range/kind, select options) before submitting
/// the data map to `POST /formats/{id}/registries`.
class NewRegistryPage extends StatefulWidget {
  final ControlFormat format;

  const NewRegistryPage({super.key, required this.format});

  @override
  State<NewRegistryPage> createState() => _NewRegistryPageState();
}

class _NewRegistryPageState extends State<NewRegistryPage> {
  final _formKey = GlobalKey<FormState>();

  /// Working values keyed by field key. BOOLEANs default to false so they are
  /// always present in the filed data.
  late final Map<String, Object?> _values = {
    for (final field in widget.format.orderedFields)
      if (field.type == FieldType.boolean) field.key: false,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newRegistryTitle)),
      body: BlocConsumer<NewRegistryCubit, NewRegistryState>(
        listener: (context, state) {
          switch (state) {
            case NewRegistrySuccess():
              context.pop(true);
            case NewRegistryFailure(:final error):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizedError(context, error))),
              );
            default:
              break;
          }
        },
        builder: (context, state) {
          final submitting = state is NewRegistrySubmitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  widget.format.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                for (final field in widget.format.orderedFields) ...[
                  _buildField(context, field),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.registrySubmit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Only send keys the user actually filled (plus booleans, which always
    // carry a value); the backend validates required fields again.
    final data = <String, Object?>{
      for (final entry in _values.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    context.read<NewRegistryCubit>().submit(widget.format.id, data);
  }

  Widget _buildField(BuildContext context, FormatField field) {
    return switch (field.type) {
      FieldType.text => _textField(context, field),
      FieldType.number => _numberField(context, field),
      FieldType.boolean => _booleanField(context, field),
      FieldType.date => _dateField(context, field),
      FieldType.select => _selectField(context, field),
    };
  }

  Widget _textField(BuildContext context, FormatField field) {
    final l10n = AppLocalizations.of(context)!;
    final rules = field.validationRules;
    return TextFormField(
      decoration: _decoration(field),
      maxLength: rules.maxLength,
      onSaved: (value) {
        final text = value?.trim() ?? '';
        _values[field.key] = text.isEmpty ? null : text;
      },
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return field.required ? l10n.validationRequired : null;
        }
        if (rules.minLength != null && text.length < rules.minLength!) {
          return l10n.validationTextMinLength('${rules.minLength}');
        }
        if (rules.maxLength != null && text.length > rules.maxLength!) {
          return l10n.validationTextMaxLength('${rules.maxLength}');
        }
        final pattern = rules.pattern;
        if (pattern != null && pattern.isNotEmpty) {
          try {
            if (!RegExp(pattern).hasMatch(text)) {
              return l10n.validationPattern;
            }
          } catch (_) {
            // An invalid server-side regex must not brick the form.
          }
        }
        return null;
      },
    );
  }

  Widget _numberField(BuildContext context, FormatField field) {
    final l10n = AppLocalizations.of(context)!;
    final rules = field.validationRules;
    return TextFormField(
      decoration: _decoration(field),
      keyboardType: TextInputType.numberWithOptions(
        decimal: !rules.integerOnly,
        signed: true,
      ),
      onSaved: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          _values[field.key] = null;
        } else {
          final parsed = num.tryParse(text);
          _values[field.key] =
              rules.integerOnly ? parsed?.toInt() : parsed;
        }
      },
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return field.required ? l10n.validationRequired : null;
        }
        final parsed = num.tryParse(text);
        if (parsed == null) return l10n.validationNumberRequired;
        if (rules.integerOnly && parsed % 1 != 0) {
          return l10n.validationNumberInteger;
        }
        if (rules.min != null && parsed < rules.min!) {
          return l10n.validationNumberMin(_trimZeros(rules.min!));
        }
        if (rules.max != null && parsed > rules.max!) {
          return l10n.validationNumberMax(_trimZeros(rules.max!));
        }
        return null;
      },
    );
  }

  Widget _booleanField(BuildContext context, FormatField field) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: SwitchListTile(
        title: Text(field.label),
        value: (_values[field.key] as bool?) ?? false,
        onChanged: (v) => setState(() => _values[field.key] = v),
      ),
    );
  }

  Widget _dateField(BuildContext context, FormatField field) {
    final l10n = AppLocalizations.of(context)!;
    return FormField<DateTime>(
      validator: (_) {
        if (field.required && _values[field.key] == null) {
          return l10n.validationRequired;
        }
        return null;
      },
      builder: (state) {
        final selected = _values[field.key] as String?;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              setState(() {
                // ISO date (yyyy-MM-dd) — a stable wire format for the
                // registry's data map.
                _values[field.key] =
                    picked.toIso8601String().substring(0, 10);
              });
              state.didChange(picked);
            }
          },
          child: InputDecorator(
            decoration: _decoration(field).copyWith(
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: Text(selected ?? l10n.fieldDateHint),
          ),
        );
      },
    );
  }

  Widget _selectField(BuildContext context, FormatField field) {
    final l10n = AppLocalizations.of(context)!;
    final options = field.validationRules.options;
    return DropdownButtonFormField<String>(
      decoration: _decoration(field),
      initialValue: _values[field.key] as String?,
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (v) => setState(() => _values[field.key] = v),
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return l10n.validationSelectRequired;
        }
        return null;
      },
    );
  }

  InputDecoration _decoration(FormatField field) {
    return InputDecoration(
      labelText: field.required ? '${field.label} *' : field.label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static String _trimZeros(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();
}
