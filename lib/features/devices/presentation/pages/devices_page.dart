import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/devices_state.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_card.dart';
import 'package:cocina360/features/devices/presentation/widgets/devices_summary.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';

/// Devices tab: the active organization's IoT devices (read-only). The active
/// organization comes from the global [OrganizationCubit] (also switched from
/// the drawer), so the list reloads whenever it changes.
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
    // The org may already be loaded before our listener attaches.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OrganizationCubit>().state;
      if (state is OrganizationLoaded) {
        context.read<DevicesCubit>().load(state.organization.id);
      }
    });
  }

  void _reload() {
    final state = context.read<OrganizationCubit>().state;
    if (state is OrganizationLoaded) {
      context.read<DevicesCubit>().load(state.organization.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.devicesTitle)),
      body: BlocListener<OrganizationCubit, OrganizationState>(
        listenWhen: (prev, curr) => curr is OrganizationLoaded,
        listener: (context, state) {
          if (state is OrganizationLoaded) {
            context.read<DevicesCubit>().load(state.organization.id);
          }
        },
        child: BlocBuilder<OrganizationCubit, OrganizationState>(
          builder: (context, orgState) {
            return switch (orgState) {
              OrganizationLoaded() => _DevicesBody(onRetry: _reload),
              OrganizationEmpty() => _Centered(
                icon: Icons.apartment_outlined,
                message: l10n.devicesSelectOrganization,
              ),
              OrganizationError(:final error) => _Centered(
                icon: Icons.cloud_off,
                message: localizedError(context, error),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }
}

class _DevicesBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _DevicesBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        return switch (state) {
          DevicesInitial() || DevicesLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DevicesError(:final error) => _ErrorView(
            message: localizedError(context, error),
            onRetry: onRetry,
          ),
          DevicesLoaded(:final devices, :final edge) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              DevicesSummary(
                total: devices.length,
                active: state.activeCount,
                edge: edge,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.devicesInventoryTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.devicesEmpty),
                  ),
                )
              else
                ...devices.map(
                  (d) => DeviceCard(
                    device: d,
                    onTap: () =>
                        context.push(AppRoutes.deviceDetail, extra: d),
                  ),
                ),
            ],
          ),
        };
      },
    );
  }
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final String message;

  const _Centered({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.devicesLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
