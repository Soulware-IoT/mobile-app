import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_device_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_device_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Claims a factory-provisioned IoT device into the organization by its code
/// (read off the device). Custom calibration thresholds are optional — the
/// backend applies standard defaults (35/50 °C, 1000/3000 PPM) when omitted.
class ClaimDevicePage extends StatefulWidget {
  final String organizationId;

  const ClaimDevicePage({super.key, required this.organizationId});

  @override
  State<ClaimDevicePage> createState() => _ClaimDevicePageState();
}

class _ClaimDevicePageState extends State<ClaimDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _tempWarnController = TextEditingController();
  final _tempCritController = TextEditingController();
  final _gasWarnController = TextEditingController();
  final _gasCritController = TextEditingController();
  bool _customThresholds = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _tempWarnController.dispose();
    _tempCritController.dispose();
    _gasWarnController.dispose();
    _gasCritController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Thresholds? thresholds;
    if (_customThresholds) {
      thresholds = Thresholds(
        warnTemperatureC: int.parse(_tempWarnController.text),
        critTemperatureC: int.parse(_tempCritController.text),
        warnGasPpm: double.parse(_gasWarnController.text),
        critGasPpm: double.parse(_gasCritController.text),
      );
    }

    context.read<ClaimDeviceCubit>().claim(
      organizationId: widget.organizationId,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      thresholds: thresholds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.claimDeviceTitle)),
      body: BlocConsumer<ClaimDeviceCubit, ClaimDeviceState>(
        listener: (context, state) {
          if (state is ClaimDeviceSuccess) {
            context.pop(true);
          } else if (state is ClaimDeviceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        builder: (context, state) {
          final claiming = state is ClaimDeviceClaiming;
          return AbsorbPointer(
            absorbing: claiming,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(
                    l10n.claimDeviceIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    enabled: !claiming,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.claimDeviceCodeLabel,
                      prefixIcon: const Icon(Icons.qr_code_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: !claiming,
                    decoration: InputDecoration(
                      labelText: l10n.deviceNameLabel,
                      prefixIcon: const Icon(Icons.sensors),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.deviceNameRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _customThresholds,
                    onChanged: claiming
                        ? null
                        : (v) => setState(() => _customThresholds = v),
                    title: Text(l10n.claimDeviceCustomThresholds),
                    subtitle: Text(l10n.claimDeviceDefaultThresholdsHint),
                  ),
                  if (_customThresholds) ...[
                    const SizedBox(height: 8),
                    _numberField(
                      _tempWarnController,
                      l10n.deviceTempWarn,
                      claiming,
                      integer: true,
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      _tempCritController,
                      l10n.deviceTempCrit,
                      claiming,
                      integer: true,
                      mustExceed: _tempWarnController,
                    ),
                    const SizedBox(height: 12),
                    _numberField(_gasWarnController, l10n.deviceGasWarn, claiming),
                    const SizedBox(height: 12),
                    _numberField(
                      _gasCritController,
                      l10n.deviceGasCrit,
                      claiming,
                      mustExceed: _gasWarnController,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: claiming ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: claiming
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.claimDeviceSubmit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    bool disabled, {
    bool integer = false,
    TextEditingController? mustExceed,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: !disabled,
      keyboardType: TextInputType.numberWithOptions(
        decimal: !integer,
        signed: true,
      ),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final parsed = double.tryParse(value ?? '');
        if (parsed == null) return l10n.validationNumberRequired;
        if (integer && parsed % 1 != 0) return l10n.validationNumberInteger;
        if (mustExceed != null) {
          final lower = double.tryParse(mustExceed.text);
          if (lower != null && parsed <= lower) {
            return l10n.deviceThresholdCritAboveWarn;
          }
        }
        return null;
      },
    );
  }
}
