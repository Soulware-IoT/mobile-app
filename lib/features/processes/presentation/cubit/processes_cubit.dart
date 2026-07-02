import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/features/processes/domain/repositories/internal_control_repository.dart';
import 'package:cocina360/features/processes/presentation/cubit/processes_state.dart';

/// Drives the Processes tab: organization → processes → formats → registries.
/// Selecting a process loads its formats; selecting a format loads its
/// registries. The first item of each level is auto-selected.
class ProcessesCubit extends Cubit<ProcessesState> {
  final InternalControlRepository repository;

  ProcessesCubit(this.repository) : super(const ProcessesState());

  String? _organizationId;

  Future<void> load(String organizationId) async {
    _organizationId = organizationId;
    emit(const ProcessesState(loadingProcesses: true));
    try {
      final processes = await repository.getProcesses(organizationId);
      emit(ProcessesState(processes: processes));
      if (processes.isNotEmpty) {
        await selectProcess(processes.first);
      }
    } catch (e) {
      emit(ProcessesState(processesError: e));
    }
  }

  Future<void> refresh() async {
    final orgId = _organizationId;
    if (orgId != null) await load(orgId);
  }

  Future<void> selectProcess(ControlProcess process) async {
    emit(state.copyWith(
      selectedProcess: process,
      loadingFormats: true,
      formats: const [],
      clearSelectedFormat: true,
      registries: const [],
    ));
    try {
      final formats = await repository.getFormats(process.id);
      emit(state.copyWith(loadingFormats: false, formats: formats));
      if (formats.isNotEmpty) {
        await selectFormat(formats.first);
      }
    } catch (e) {
      emit(state.copyWith(loadingFormats: false, formatsError: e));
    }
  }

  Future<void> selectFormat(ControlFormat format) async {
    emit(state.copyWith(
      selectedFormat: format,
      loadingRegistries: true,
      registries: const [],
    ));
    try {
      final registries = await repository.getRegistries(format.id);
      // Newest first — the screen shows them as "recent logs".
      registries.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      emit(state.copyWith(loadingRegistries: false, registries: registries));
    } catch (e) {
      emit(state.copyWith(loadingRegistries: false, registriesError: e));
    }
  }

  /// Reloads the selected format's registries (e.g. after filing a new one).
  Future<void> reloadRegistries() async {
    final format = state.selectedFormat;
    if (format != null) await selectFormat(format);
  }

  Future<void> createProcess(String name) async {
    final orgId = _organizationId;
    if (orgId == null) return;
    try {
      final created = await repository.createProcess(orgId, name);
      emit(state.copyWith(processes: [...state.processes, created]));
      await selectProcess(created);
    } catch (e) {
      emit(state.copyWith(actionError: e));
    }
  }

  Future<void> createFormat(String name, {bool sampleFields = false}) async {
    final process = state.selectedProcess;
    if (process == null) return;
    try {
      final created = await repository.createFormat(
        process.id,
        name,
        createSampleFields: sampleFields,
      );
      emit(state.copyWith(formats: [...state.formats, created]));
      await selectFormat(created);
    } catch (e) {
      emit(state.copyWith(actionError: e));
    }
  }

  Future<void> applyFormatAction(FormatAction action) async {
    final format = state.selectedFormat;
    if (format == null) return;
    try {
      final updated = await repository.transitionFormat(format.id, action);
      final formats = state.formats
          .map((f) => f.id == updated.id ? updated : f)
          .toList();
      emit(state.copyWith(formats: formats, selectedFormat: updated));
    } catch (e) {
      emit(state.copyWith(actionError: e));
    }
  }
}
