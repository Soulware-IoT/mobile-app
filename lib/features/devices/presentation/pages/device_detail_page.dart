import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_badge.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_label.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Detail of an IoT device: identity (with rename), configured thresholds
/// (editable), operational controls (activate / deactivate) and metadata.
/// Shows the device passed via `extra` immediately, then refreshes it through
/// `GET /iot-devices/{id}`.
class DeviceDetailPage extends StatefulWidget {
  final IotDevice device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceDetailCubit>().load(widget.device.deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: BlocConsumer<DeviceDetailCubit, DeviceDetailState>(
        listenWhen: (prev, curr) =>
            curr is DeviceDetailLoaded && curr.updateError != null,
        listener: (context, state) {
          final error = (state as DeviceDetailLoaded).updateError!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedError(context, error))),
          );
        },
        builder: (context, state) {
          // Fall back to the device handed in via `extra` while the refresh is
          // in flight, so the screen is never blank.
          final device = switch (state) {
            DeviceDetailLoaded(:final device) => device,
            _ => widget.device,
          };
          final updating = state is DeviceDetailLoaded && state.updating;

          if (state is DeviceDetailError) {
            return _ErrorView(
              message: localizedError(context, state.error),
              onRetry: () => context.read<DeviceDetailCubit>().load(
                widget.device.deviceId,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _HeaderCard(device: device, updating: updating),
              const SizedBox(height: 16),
              _ControlsCard(device: device, updating: updating),
              const SizedBox(height: 16),
              _ThresholdsCard(device: device, updating: updating),
              const SizedBox(height: 16),
              _MetadataCard(device: device),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IotDevice device;
  final bool updating;

  const _HeaderCard({required this.device, required this.updating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sensors, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.code,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.deviceRenameTooltip,
            onPressed: updating ? null : () => _showRenameDialog(context),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          DeviceStatusBadge(status: device.status),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DeviceDetailCubit>();
    final controller = TextEditingController(text: device.name);
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deviceRenameTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(labelText: l10n.deviceNameLabel),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.deviceNameRequired
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );

    if (name != null && name != device.name) {
      await cubit.rename(device.deviceId, name);
    }
  }
}

/// Operational controls: one prominent action that flips the device's
/// activation, mirroring the backend's `PATCH status` (ACTIVE / INACTIVE).
class _ControlsCard extends StatelessWidget {
  final IotDevice device;
  final bool updating;

  const _ControlsCard({required this.device, required this.updating});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final active = device.status == DeviceStatus.active;
    final provisioned = device.status == DeviceStatus.provisioned;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(context, l10n.deviceControlsTitle),
              Text(
                device.status.localizedLabel(l10n),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (provisioned)
            // An unclaimed device cannot be operated.
            Text(
              l10n.deviceControlsProvisioned,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: active
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  foregroundColor: active
                      ? theme.colorScheme.onError
                      : theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: updating
                    ? null
                    : () => _confirmToggle(context, active),
                icon: updating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        active
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                      ),
                label: Text(
                  active ? l10n.deviceDeactivate : l10n.deviceActivate,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmToggle(BuildContext context, bool active) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DeviceDetailCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          active ? l10n.deviceDeactivateConfirmTitle : l10n.deviceActivateConfirmTitle,
        ),
        content: Text(
          active ? l10n.deviceDeactivateConfirmBody : l10n.deviceActivateConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.setActive(device.deviceId, !active);
    }
  }
}

class _ThresholdsCard extends StatelessWidget {
  final IotDevice device;
  final bool updating;

  const _ThresholdsCard({required this.device, required this.updating});

  @override
  Widget build(BuildContext context) {
    final t = device.thresholds;
    final l10n = AppLocalizations.of(context)!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(context, l10n.deviceThresholdsTitle),
              IconButton(
                tooltip: l10n.deviceThresholdsEditTooltip,
                onPressed:
                    updating ? null : () => _showEditDialog(context),
                icon: const Icon(Icons.tune, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (t.isEmpty)
            Text(l10n.deviceThresholdsEmpty)
          else ...[
            _Row(label: l10n.deviceTempWarn, value: _temp(t.warnTemperatureC)),
            _Row(label: l10n.deviceTempCrit, value: _temp(t.critTemperatureC)),
            _Row(label: l10n.deviceGasWarn, value: _gas(t.warnGasPpm)),
            _Row(label: l10n.deviceGasCrit, value: _gas(t.critGasPpm)),
          ],
        ],
      ),
    );
  }

  String _temp(int? v) => v == null ? '—' : '$v °C';
  String _gas(double? v) => v == null ? '—' : '$v ppm';

  Future<void> _showEditDialog(BuildContext context) async {
    final cubit = context.read<DeviceDetailCubit>();
    final result = await showDialog<Thresholds>(
      context: context,
      builder: (_) => _ThresholdsDialog(current: device.thresholds),
    );
    if (result != null) {
      await cubit.updateThresholds(device.deviceId, result);
    }
  }
}

/// Edits the four calibration limits. The backend requires all four values
/// with warn < crit per magnitude — enforced here before submitting.
class _ThresholdsDialog extends StatefulWidget {
  final Thresholds current;

  const _ThresholdsDialog({required this.current});

  @override
  State<_ThresholdsDialog> createState() => _ThresholdsDialogState();
}

class _ThresholdsDialogState extends State<_ThresholdsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tempWarn;
  late final TextEditingController _tempCrit;
  late final TextEditingController _gasWarn;
  late final TextEditingController _gasCrit;

  @override
  void initState() {
    super.initState();
    _tempWarn = TextEditingController(
      text: widget.current.warnTemperatureC?.toString() ?? '',
    );
    _tempCrit = TextEditingController(
      text: widget.current.critTemperatureC?.toString() ?? '',
    );
    _gasWarn = TextEditingController(
      text: widget.current.warnGasPpm?.toString() ?? '',
    );
    _gasCrit = TextEditingController(
      text: widget.current.critGasPpm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _tempWarn.dispose();
    _tempCrit.dispose();
    _gasWarn.dispose();
    _gasCrit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.deviceThresholdsTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _numberField(_tempWarn, l10n.deviceTempWarn, l10n),
              _numberField(_tempCrit, l10n.deviceTempCrit, l10n,
                  mustExceed: _tempWarn),
              _numberField(_gasWarn, l10n.deviceGasWarn, l10n),
              _numberField(_gasCrit, l10n.deviceGasCrit, l10n,
                  mustExceed: _gasWarn),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.saveChanges),
        ),
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    AppLocalizations l10n, {
    TextEditingController? mustExceed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final parsed = double.tryParse(value ?? '');
          if (parsed == null) return l10n.validationNumberRequired;
          if (mustExceed != null) {
            final lower = double.tryParse(mustExceed.text);
            if (lower != null && parsed <= lower) {
              return l10n.deviceThresholdCritAboveWarn;
            }
          }
          return null;
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Thresholds(
        warnTemperatureC: int.parse(double.parse(_tempWarn.text).toStringAsFixed(0)),
        critTemperatureC: int.parse(double.parse(_tempCrit.text).toStringAsFixed(0)),
        warnGasPpm: double.parse(_gasWarn.text),
        critGasPpm: double.parse(_gasCrit.text),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  final IotDevice device;

  const _MetadataCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, l10n.deviceMetadataTitle),
          const SizedBox(height: 12),
          _Row(
            label: l10n.deviceStatusFieldLabel,
            value: device.status.localizedLabel(l10n),
          ),
          _Row(label: l10n.deviceCreatedLabel, value: _date(device.createdAt)),
          _Row(label: l10n.deviceUpdatedLabel, value: _date(device.updatedAt)),
        ],
      ),
    );
  }

  String _date(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

Widget _sectionTitle(BuildContext context, String text) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
);

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
