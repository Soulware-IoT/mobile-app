import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/features/processes/domain/model/control_registry.dart';

abstract class InternalControlRepository {
  /// Control processes of the organization.
  Future<List<ControlProcess>> getProcesses(String organizationId);

  /// Creates a control process (backend requires INTERNAL_CONTROL admin).
  Future<ControlProcess> createProcess(String organizationId, String name);

  /// Formats (document templates) of a process.
  Future<List<ControlFormat>> getFormats(String processId);

  /// Creates a format; [createSampleFields] seeds it with example fields.
  Future<ControlFormat> createFormat(
    String processId,
    String name, {
    bool createSampleFields = false,
  });

  /// Moves the format through its lifecycle (activate / suspend / resume /
  /// cease), returning the new state.
  Future<ControlFormat> transitionFormat(
    String formatId,
    FormatAction action,
  );

  /// Filled registries of a format (backend requires INTERNAL_CONTROL
  /// lieutenant to list).
  Future<List<ControlRegistry>> getRegistries(String formatId);

  /// Files a new registry with the given field values, keyed by field key.
  Future<ControlRegistry> createRegistry(
    String formatId,
    Map<String, Object?> data,
  );
}
