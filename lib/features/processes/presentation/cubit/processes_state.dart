import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/features/processes/domain/model/control_registry.dart';

/// Composite state of the Processes tab: the org's processes, the selected
/// process's formats, and the selected format's registries. Each level keeps
/// its own loading flag and error so a failure at one depth (e.g. listing
/// registries needs a higher permission) degrades only that section.
class ProcessesState {
  final bool loadingProcesses;
  final Object? processesError;
  final List<ControlProcess> processes;
  final ControlProcess? selectedProcess;

  final bool loadingFormats;
  final Object? formatsError;
  final List<ControlFormat> formats;
  final ControlFormat? selectedFormat;

  final bool loadingRegistries;
  final Object? registriesError;
  final List<ControlRegistry> registries;

  /// Set when a mutation (create process/format, lifecycle) fails; surfaced as
  /// a snackbar and cleared on the next event.
  final Object? actionError;

  const ProcessesState({
    this.loadingProcesses = false,
    this.processesError,
    this.processes = const [],
    this.selectedProcess,
    this.loadingFormats = false,
    this.formatsError,
    this.formats = const [],
    this.selectedFormat,
    this.loadingRegistries = false,
    this.registriesError,
    this.registries = const [],
    this.actionError,
  });

  ProcessesState copyWith({
    bool? loadingProcesses,
    Object? processesError,
    List<ControlProcess>? processes,
    ControlProcess? selectedProcess,
    bool clearSelectedProcess = false,
    bool? loadingFormats,
    Object? formatsError,
    List<ControlFormat>? formats,
    ControlFormat? selectedFormat,
    bool clearSelectedFormat = false,
    bool? loadingRegistries,
    Object? registriesError,
    List<ControlRegistry>? registries,
    Object? actionError,
  }) {
    return ProcessesState(
      loadingProcesses: loadingProcesses ?? this.loadingProcesses,
      processesError: processesError,
      processes: processes ?? this.processes,
      selectedProcess: clearSelectedProcess
          ? null
          : (selectedProcess ?? this.selectedProcess),
      loadingFormats: loadingFormats ?? this.loadingFormats,
      formatsError: formatsError,
      formats: formats ?? this.formats,
      selectedFormat:
          clearSelectedFormat ? null : (selectedFormat ?? this.selectedFormat),
      loadingRegistries: loadingRegistries ?? this.loadingRegistries,
      registriesError: registriesError,
      registries: registries ?? this.registries,
      actionError: actionError,
    );
  }
}
