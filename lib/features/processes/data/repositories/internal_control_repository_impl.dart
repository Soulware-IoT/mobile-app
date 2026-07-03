import 'package:cocina360/features/processes/data/services/internal_control_remote_service.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/features/processes/domain/model/control_process.dart';
import 'package:cocina360/features/processes/domain/model/control_registry.dart';
import 'package:cocina360/features/processes/domain/repositories/internal_control_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';

class InternalControlRepositoryImpl implements InternalControlRepository {
  final InternalControlRemoteService remoteService;
  final NetworkChecker connectionChecker;

  InternalControlRepositoryImpl(this.remoteService, this.connectionChecker);

  @override
  Future<List<ControlProcess>> getProcesses(String organizationId) async {
    await _requireConnection();
    final dtos = await remoteService.getProcesses(organizationId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<ControlProcess> createProcess(
    String organizationId,
    String name,
  ) async {
    await _requireConnection();
    return (await remoteService.createProcess(organizationId, name))
        .toDomain();
  }

  @override
  Future<List<ControlFormat>> getFormats(String processId) async {
    await _requireConnection();
    final dtos = await remoteService.getFormats(processId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<ControlFormat> createFormat(
    String processId,
    String name, {
    bool createSampleFields = false,
  }) async {
    await _requireConnection();
    return (await remoteService.createFormat(
      processId,
      name,
      createSampleFields: createSampleFields,
    ))
        .toDomain();
  }

  @override
  Future<ControlFormat> transitionFormat(
    String formatId,
    FormatAction action,
  ) async {
    await _requireConnection();
    return (await remoteService.transitionFormat(formatId, action.name))
        .toDomain();
  }

  @override
  Future<List<ControlRegistry>> getRegistries(String formatId) async {
    await _requireConnection();
    final dtos = await remoteService.getRegistries(formatId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<ControlRegistry> createRegistry(
    String formatId,
    Map<String, Object?> data,
  ) async {
    await _requireConnection();
    return (await remoteService.createRegistry(formatId, data)).toDomain();
  }

  Future<void> _requireConnection() async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }
  }
}
