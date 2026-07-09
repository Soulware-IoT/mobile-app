import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/features/processes/presentation/cubit/processes_cubit.dart';
import 'package:cocina360/features/processes/presentation/cubit/processes_state.dart';
import 'package:cocina360/features/processes/presentation/widgets/format_status_chip.dart';
import 'package:cocina360/features/processes/presentation/widgets/registry_card.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';

/// Processes tab: the active organization's internal-control processes, the
/// selected process's document formats, and the selected format's recent
/// registries. The FAB files a new registry against the selected format.
class ProcessesPage extends StatefulWidget {
  const ProcessesPage({super.key});

  @override
  State<ProcessesPage> createState() => _ProcessesPageState();
}

class _ProcessesPageState extends State<ProcessesPage> {
  @override
  void initState() {
    super.initState();
    // The org may already be loaded before our listener attaches.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OrganizationCubit>().state;
      if (state is OrganizationLoaded) {
        context.read<ProcessesCubit>().load(state.organization.id);
      }
    });
  }

  void _reload() {
    final state = context.read<OrganizationCubit>().state;
    if (state is OrganizationLoaded) {
      context.read<ProcessesCubit>().load(state.organization.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.processesTitle),
        actions: [
          // Creating a process needs an active organization — hide the action
          // entirely when there is none, mirroring the Devices tab's gating.
          BlocBuilder<OrganizationCubit, OrganizationState>(
            builder: (context, orgState) {
              if (orgState is! OrganizationLoaded) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: l10n.processesNewProcess,
                onPressed: () => _showCreateProcessDialog(context),
                icon: const Icon(Icons.playlist_add),
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ProcessesCubit, ProcessesState>(
        builder: (context, state) {
          final format = state.selectedFormat;
          if (format == null) return const SizedBox.shrink();
          return FloatingActionButton(
            // AppShell keeps all tabs mounted via IndexedStack, so this and
            // the Devices tab's FAB coexist in the tree at once — without a
            // distinct tag both would collide on Flutter's default Hero tag.
            heroTag: 'processes-new-registry-fab',
            tooltip: l10n.newRegistryTitle,
            onPressed: () => _onNewRegistry(context, format),
            child: const Icon(Icons.add),
          );
        },
      ),
      body: BlocListener<OrganizationCubit, OrganizationState>(
        listenWhen: (prev, curr) => curr is OrganizationLoaded,
        listener: (context, state) {
          if (state is OrganizationLoaded) {
            context.read<ProcessesCubit>().load(state.organization.id);
          }
        },
        child: BlocBuilder<OrganizationCubit, OrganizationState>(
          builder: (context, orgState) {
            return switch (orgState) {
              OrganizationLoaded() => _ProcessesBody(onRetry: _reload),
              OrganizationEmpty() => _Centered(
                icon: Icons.apartment_outlined,
                message: l10n.processesSelectOrganization,
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

  Future<void> _onNewRegistry(BuildContext context, ControlFormat format) async {
    final l10n = AppLocalizations.of(context)!;
    if (!format.status.acceptsRegistries) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.processesFormatNotActive)),
      );
      return;
    }
    final cubit = context.read<ProcessesCubit>();
    final created = await context.push<bool>(
      AppRoutes.newRegistry,
      extra: format,
    );
    if (created == true) {
      await cubit.reloadRegistries();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.processesRegistryCreated)),
        );
      }
    }
  }

  Future<void> _showCreateProcessDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProcessesCubit>();
    final name = await _promptName(
      context,
      title: l10n.processesNewProcess,
      label: l10n.processesProcessNameLabel,
    );
    if (name != null) await cubit.createProcess(name);
  }
}

class _ProcessesBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProcessesBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<ProcessesCubit, ProcessesState>(
      listenWhen: (prev, curr) => curr.actionError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizedError(context, state.actionError!))),
        );
      },
      builder: (context, state) {
        if (state.loadingProcesses) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.processesError != null) {
          return _ErrorView(
            message: localizedError(context, state.processesError!),
            onRetry: onRetry,
          );
        }
        if (state.processes.isEmpty) {
          return _Centered(
            icon: Icons.account_tree_outlined,
            message: l10n.processesEmpty,
            hint: l10n.processesCreateFirst,
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ProcessesCubit>().refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [
              Text(
                l10n.processesHeaderLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.selectedProcess?.name ?? l10n.processesTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              _ProcessSelector(state: state),
              const SizedBox(height: 12),
              _FormatSelector(state: state),
              const SizedBox(height: 24),
              _RegistriesSection(state: state),
            ],
          ),
        );
      },
    );
  }
}

/// Dropdown-style card to pick the control process.
class _ProcessSelector extends StatelessWidget {
  final ProcessesState state;

  const _ProcessSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SelectorCard<ControlProcess>(
      icon: Icons.shield_outlined,
      label: l10n.processesSectionProcesses,
      value: state.selectedProcess,
      items: state.processes,
      itemLabel: (p) => p.name,
      onSelected: (p) => context.read<ProcessesCubit>().selectProcess(p),
    );
  }
}

/// Dropdown-style card to pick the document format, with its status chip and
/// lifecycle actions.
class _FormatSelector extends StatelessWidget {
  final ProcessesState state;

  const _FormatSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.loadingFormats) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.formatsError != null) {
      return _InlineError(
        message: localizedError(context, state.formatsError!),
      );
    }

    final selected = state.selectedFormat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SelectorCard<ControlFormat>(
          icon: Icons.article_outlined,
          label: l10n.processesSectionFormats,
          value: selected,
          items: state.formats,
          itemLabel: (f) => f.name,
          emptyLabel: l10n.processesNoFormats,
          trailing: selected == null
              ? null
              : FormatStatusChip(status: selected.status),
          onSelected: (f) => context.read<ProcessesCubit>().selectFormat(f),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selected != null &&
                selected.status.availableActions.isNotEmpty)
              _FormatActionsButton(format: selected),
            TextButton.icon(
              onPressed: () => _showCreateFormatDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.processesNewFormat),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCreateFormatDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProcessesCubit>();
    var sampleFields = true;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l10n.processesNewFormat),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: l10n.processesFormatNameLabel,
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? l10n.processesNameRequired
                          : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: sampleFields,
                  onChanged: (v) => setState(() => sampleFields = v ?? false),
                  title: Text(l10n.processesSampleFields),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await cubit.createFormat(
        controller.text.trim(),
        sampleFields: sampleFields,
      );
    }
  }
}

/// Popup with the lifecycle transitions the backend allows from the format's
/// current status.
class _FormatActionsButton extends StatelessWidget {
  final ControlFormat format;

  const _FormatActionsButton({required this.format});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<FormatAction>(
      onSelected: (action) =>
          context.read<ProcessesCubit>().applyFormatAction(action),
      itemBuilder: (context) => [
        for (final action in format.status.availableActions)
          PopupMenuItem(
            value: action,
            child: Text(action.localizedLabel(l10n)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz, size: 18),
            const SizedBox(width: 4),
            Text(format.status.localizedLabel(l10n)),
          ],
        ),
      ),
    );
  }
}

class _RegistriesSection extends StatelessWidget {
  final ProcessesState state;

  const _RegistriesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final format = state.selectedFormat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.processesRecentLogs,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        if (format == null)
          Text(l10n.processesNoFormats)
        else if (state.loadingRegistries)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.registriesError != null)
          _InlineError(
            message: localizedError(context, state.registriesError!),
          )
        else if (state.registries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text(l10n.processesNoRegistries)),
          )
        else
          ...state.registries.map(
            (r) => RegistryCard(registry: r, format: format),
          ),
      ],
    );
  }
}

/// Shared dropdown-style card: an icon, a label, the selected item and a
/// chevron that opens a modal sheet with the options.
class _SelectorCard<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;
  final String? emptyLabel;
  final Widget? trailing;

  const _SelectorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.emptyLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = value != null
        ? itemLabel(value as T)
        : (items.isEmpty ? (emptyLabel ?? label) : label);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: items.isEmpty ? null : () => _openOptions(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }

  void _openOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in items)
              ListTile(
                leading: Icon(
                  item == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(itemLabel(item)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelected(item);
                },
              ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptName(
  BuildContext context, {
  required String title,
  required String label,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(labelText: label),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? l10n.processesNameRequired
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
          child: Text(l10n.create),
        ),
      ],
    ),
  );
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;

  const _Centered({required this.icon, required this.message, this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
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
