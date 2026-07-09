import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/reading_severity.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/servo_command_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/servo_command_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/reading_line_chart.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Per-device monitor for the Live Readings page: header with presence pill,
/// servo start/stop controls, the latest-reading status strip and the two
/// threshold-annotated charts.
class LiveMonitorPanel extends StatelessWidget {
  final IotDevice device;
  final DevicePresence? presence;
  final SensorReading? latest;
  final List<SensorReading> history;

  const LiveMonitorPanel({
    super.key,
    required this.device,
    required this.presence,
    required this.latest,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      device.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _PresencePill(presence: presence),
            ],
          ),
          const SizedBox(height: 16),
          _ServoControls(deviceId: device.deviceId),
          const SizedBox(height: 16),
          _StatusStrip(latest: latest),
          const SizedBox(height: 20),
          Text(
            l10n.chartTemperatureTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ReadingLineChart(
            values: [
              for (final r in history) r.temperatureC.toDouble(),
            ],
            warn: device.thresholds.warnTemperatureC?.toDouble(),
            crit: device.thresholds.critTemperatureC?.toDouble(),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.chartGasTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ReadingLineChart(
            values: [for (final r in history) r.gasPpm],
            warn: device.thresholds.warnGasPpm,
            crit: device.thresholds.critGasPpm,
          ),
        ],
      ),
    );
  }
}

class _PresencePill extends StatelessWidget {
  final DevicePresence? presence;

  const _PresencePill({required this.presence});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg, label) = switch (presence) {
      DevicePresence(online: true) => (
        const Color(0xFFD7F2DD),
        const Color(0xFF1B7A3D),
        l10n.liveReadingsOnline,
      ),
      DevicePresence(online: false) => (
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ServoControls extends StatelessWidget {
  final String deviceId;

  const _ServoControls({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ServoCommandCubit, ServoCommandState>(
      builder: (context, state) {
        final sending = state is ServoSending;
        final sendingCommand = state is ServoSending ? state.command : null;

        Widget icon(ServoCommand command, IconData idle) =>
            sendingCommand == command
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(idle, size: 18);

        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: sending
                    ? null
                    : () => context.read<ServoCommandCubit>().send(
                        deviceId,
                        ServoCommand.start,
                      ),
                icon: icon(ServoCommand.start, Icons.play_arrow),
                label: Text(l10n.servoStart),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: sending
                    ? null
                    : () => context.read<ServoCommandCubit>().send(
                        deviceId,
                        ServoCommand.stop,
                      ),
                icon: icon(ServoCommand.stop, Icons.stop),
                label: Text(l10n.servoStop),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final SensorReading? latest;

  const _StatusStrip({required this.latest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reading = latest;

    if (reading == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.liveReadingsWaiting,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final (bg, fg, label) = switch (reading.severity) {
      ReadingSeverity.safe => (
        const Color(0xFFD7F2DD),
        const Color(0xFF1B7A3D),
        l10n.severitySafe,
      ),
      ReadingSeverity.warning => (
        const Color(0xFFFCE8B2),
        const Color(0xFF7A5B00),
        l10n.severityWarning,
      ),
      ReadingSeverity.critical => (
        const Color(0xFFF8D7DA),
        const Color(0xFF9A2530),
        l10n.severityCritical,
      ),
    };

    final time = reading.occurredAt == null
        ? ''
        : DateFormat.Hms().format(reading.occurredAt!.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, color: fg),
          ),
          const SizedBox(width: 14),
          Text(
            '${reading.temperatureC} °C',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          Text(
            '${reading.gasPpm.toStringAsFixed(1)} PPM',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
