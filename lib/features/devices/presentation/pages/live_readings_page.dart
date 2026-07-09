import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/devices_state.dart';
import 'package:cocina360/features/devices/presentation/cubit/live_readings_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/live_readings_state.dart';
import 'package:cocina360/features/devices/presentation/cubit/servo_command_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/servo_command_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/live_device_selector.dart';
import 'package:cocina360/features/devices/presentation/widgets/live_monitor_panel.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Real-time sensor monitoring: pick one of the organization's IoT devices
/// and watch its readings stream in, with presence, servo controls and
/// threshold-annotated charts. Mobile counterpart of the web app's
/// "Security > Live readings" tab.
class LiveReadingsPage extends StatefulWidget {
  final String organizationId;

  const LiveReadingsPage({super.key, required this.organizationId});

  @override
  State<LiveReadingsPage> createState() => _LiveReadingsPageState();
}

class _LiveReadingsPageState extends State<LiveReadingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LiveReadingsCubit>().start(widget.organizationId);
    // Device list comes from the app-level DevicesCubit; refresh if the tab
    // hasn't loaded it yet.
    final devicesState = context.read<DevicesCubit>().state;
    if (devicesState is! DevicesLoaded) {
      context.read<DevicesCubit>().load(widget.organizationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveReadingsTitle)),
      body: BlocListener<ServoCommandCubit, ServoCommandState>(
        listener: (context, state) {
          if (state is ServoFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        child: BlocBuilder<LiveReadingsCubit, LiveReadingsState>(
          builder: (context, state) => switch (state) {
            LiveReadingsInitial() || LiveReadingsConnecting() => const Center(
              child: CircularProgressIndicator(),
            ),
            LiveReadingsError(:final error) => _ErrorView(
              message: localizedError(context, error),
              onRetry: () => context.read<LiveReadingsCubit>().start(
                widget.organizationId,
              ),
            ),
            LiveReadingsActive() => _ActiveView(
              state: state,
              organizationId: widget.organizationId,
            ),
          },
        ),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  final LiveReadingsActive state;
  final String organizationId;

  const _ActiveView({required this.state, required this.organizationId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, devicesState) {
        final devices = switch (devicesState) {
          DevicesLoaded(:final devices) => devices,
          _ => const <IotDevice>[],
        };

        final selected = state.selectedDeviceId == null
            ? null
            : devices
                  .where((d) => d.deviceId == state.selectedDeviceId)
                  .firstOrNull;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            if (state.reconnecting) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8B2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF7A5B00),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.liveReadingsReconnecting,
                      style: const TextStyle(
                        color: Color(0xFF7A5B00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (devices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l10n.liveReadingsNoDevices,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else ...[
              LiveDeviceSelector(
                devices: devices,
                presenceByDevice: state.presenceByDevice,
                selectedDeviceId: state.selectedDeviceId,
                onSelect: (deviceId) {
                  context.read<LiveReadingsCubit>().selectDevice(deviceId);
                  context.read<ServoCommandCubit>().reset();
                },
              ),
              const SizedBox(height: 16),
              if (selected == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.liveReadingsSelectDevice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                LiveMonitorPanel(
                  device: selected,
                  presence: state.presenceByDevice[selected.deviceId],
                  latest: state.latestByDevice[selected.deviceId],
                  history:
                      state.historyByDevice[selected.deviceId] ?? const [],
                ),
            ],
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sensors_off_outlined,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
