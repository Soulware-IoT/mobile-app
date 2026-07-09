import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/edge_device_detail_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/edge_device_detail_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_badge.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_label.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Arguments for [EdgeDeviceDetailPage]: unlike the IoT device detail page,
/// refreshing needs the organization id too (there is no `GET
/// /edge-device/{id}`, only the organization-scoped list endpoint).
class EdgeDeviceDetailArgs {
  final String organizationId;
  final EdgeDevice device;

  const EdgeDeviceDetailArgs({required this.organizationId, required this.device});
}

/// Detail of the organization's edge gateway: identity (with rename), live
/// connectivity, operational controls (activate / deactivate) and metadata.
/// Shows the device passed via `extra` immediately, then refreshes it
/// through `GET /organizations/{organizationId}/edge-device`.
class EdgeDeviceDetailPage extends StatefulWidget {
  final EdgeDeviceDetailArgs args;

  const EdgeDeviceDetailPage({super.key, required this.args});

  @override
  State<EdgeDeviceDetailPage> createState() => _EdgeDeviceDetailPageState();
}

class _EdgeDeviceDetailPageState extends State<EdgeDeviceDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EdgeDeviceDetailCubit>().load(widget.args.organizationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.device.name)),
      body: BlocConsumer<EdgeDeviceDetailCubit, EdgeDeviceDetailState>(
        listenWhen: (prev, curr) =>
            curr is EdgeDeviceDetailLoaded && curr.updateError != null,
        listener: (context, state) {
          final error = (state as EdgeDeviceDetailLoaded).updateError!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedError(context, error))),
          );
        },
        builder: (context, state) {
          // Fall back to the device handed in via `extra` while the refresh
          // is in flight, so the screen is never blank.
          final device = switch (state) {
            EdgeDeviceDetailLoaded(:final device) => device,
            _ => widget.args.device,
          };
          final updating = state is EdgeDeviceDetailLoaded && state.updating;

          if (state is EdgeDeviceDetailError) {
            return _ErrorView(
              message: localizedError(context, state.error),
              onRetry: () => context.read<EdgeDeviceDetailCubit>().load(
                widget.args.organizationId,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _HeaderCard(
                device: device,
                organizationId: widget.args.organizationId,
                updating: updating,
              ),
              const SizedBox(height: 16),
              _ControlsCard(device: device, updating: updating),
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
  final EdgeDevice device;
  final String organizationId;
  final bool updating;

  const _HeaderCard({
    required this.device,
    required this.organizationId,
    required this.updating,
  });

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
            child: Icon(
              Icons.router_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
                const SizedBox(height: 8),
                _PresenceBadge(
                  organizationId: organizationId,
                  edgeDeviceId: device.edgeDeviceId,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.edgeRenameTooltip,
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
    final cubit = context.read<EdgeDeviceDetailCubit>();
    final controller = TextEditingController(text: device.name);
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.edgeRenameTitle),
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
      await cubit.rename(name);
    }
  }
}

/// Live online/offline pill for the edge gateway, sourced from the same
/// presence snapshot + SSE stream the Live Readings page uses.
class _PresenceBadge extends StatefulWidget {
  final String organizationId;
  final String edgeDeviceId;

  const _PresenceBadge({
    required this.organizationId,
    required this.edgeDeviceId,
  });

  @override
  State<_PresenceBadge> createState() => _PresenceBadgeState();
}

class _PresenceBadgeState extends State<_PresenceBadge> {
  bool? _online;
  StreamSubscription<DevicePresence>? _subscription;

  @override
  void initState() {
    super.initState();
    final repository = context.read<TelemetryRepository>();

    repository.presenceSnapshot(widget.organizationId).then((snapshot) {
      if (!mounted) return;
      final match = snapshot
          .where((p) => p.deviceId == widget.edgeDeviceId)
          .firstOrNull;
      if (match != null) setState(() => _online = match.online);
    }).catchError((_) {
      // Non-fatal: the badge just stays in the "no signal" state.
    });

    _subscription = repository
        .presence(widget.organizationId)
        .listen(
          (presence) {
            if (presence.deviceId != widget.edgeDeviceId) return;
            if (mounted) setState(() => _online = presence.online);
          },
          onError: (_) {},
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg, label) = switch (_online) {
      true => (
        const Color(0xFFD7F2DD),
        const Color(0xFF1B7A3D),
        l10n.liveReadingsOnline,
      ),
      false => (
        const Color(0xFFF8D7DA),
        const Color(0xFF9A2530),
        l10n.liveReadingsOffline,
      ),
      null => (
        const Color(0xFFE6E8EB),
        const Color(0xFF5A6470),
        l10n.liveReadingsNoSignal,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Operational controls: one prominent action that flips the edge device's
/// activation, mirroring the backend's `PATCH status` (ACTIVE / INACTIVE).
class _ControlsCard extends StatelessWidget {
  final EdgeDevice device;
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
            // An unclaimed edge device cannot be operated.
            Text(
              l10n.edgeControlsProvisioned,
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
                label: Text(active ? l10n.edgeDeactivate : l10n.edgeActivate),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmToggle(BuildContext context, bool active) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<EdgeDeviceDetailCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          active
              ? l10n.edgeDeactivateConfirmTitle
              : l10n.edgeActivateConfirmTitle,
        ),
        content: Text(
          active
              ? l10n.edgeDeactivateConfirmBody
              : l10n.edgeActivateConfirmBody,
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
      await cubit.setActive(!active);
    }
  }
}

class _MetadataCard extends StatelessWidget {
  final EdgeDevice device;

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
          _Row(label: l10n.deviceStatusFieldLabel, value: device.status.localizedLabel(l10n)),
          _Row(label: l10n.claimDeviceCodeLabel, value: device.code),
        ],
      ),
    );
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
