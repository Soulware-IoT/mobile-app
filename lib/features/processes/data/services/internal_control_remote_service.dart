import 'package:cocina360/features/processes/data/services/dto/control_format_dto.dart';
import 'package:cocina360/features/processes/data/services/dto/control_process_dto.dart';
import 'package:cocina360/features/processes/data/services/dto/control_registry_dto.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Talks to the backend's Internal Control context through the api-gw.
class InternalControlRemoteService {
  final ApiGatewayClient client;

  InternalControlRemoteService(this.client);

  /// `GET /organizations/{organizationId}/control-processes`
  Future<List<ControlProcessDto>> getProcesses(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/control-processes',
    );
    return (data as List).cast<JSON>().map(ControlProcessDto.fromJson).toList();
  }

  /// `POST /organizations/{organizationId}/control-processes`
  Future<ControlProcessDto> createProcess(
    String organizationId,
    String name,
  ) async {
    final data = await client.postJson(
      '/organizations/$organizationId/control-processes',
      body: {'name': name},
    );
    return ControlProcessDto.fromJson(data as JSON);
  }

  /// `GET /control-processes/{processId}/formats`
  Future<List<ControlFormatDto>> getFormats(String processId) async {
    final data = await client.getJson('/control-processes/$processId/formats');
    return (data as List).cast<JSON>().map(ControlFormatDto.fromJson).toList();
  }

  /// `POST /control-processes/{processId}/formats`
  Future<ControlFormatDto> createFormat(
    String processId,
    String name, {
    bool createSampleFields = false,
  }) async {
    final data = await client.postJson(
      '/control-processes/$processId/formats',
      body: {'name': name, 'createSampleFields': createSampleFields},
    );
    return ControlFormatDto.fromJson(data as JSON);
  }

  /// `POST /formats/{id}/{activate|suspend|resume|cease}`
  Future<ControlFormatDto> transitionFormat(
    String formatId,
    String action,
  ) async {
    final data = await client.postJson('/formats/$formatId/$action');
    return ControlFormatDto.fromJson(data as JSON);
  }

  /// `GET /formats/{formatId}/registries`
  Future<List<ControlRegistryDto>> getRegistries(String formatId) async {
    final data = await client.getJson('/formats/$formatId/registries');
    return (data as List)
        .cast<JSON>()
        .map(ControlRegistryDto.fromJson)
        .toList();
  }

  /// `POST /formats/{formatId}/registries`
  Future<ControlRegistryDto> createRegistry(
    String formatId,
    Map<String, Object?> data,
  ) async {
    final response = await client.postJson(
      '/formats/$formatId/registries',
      body: {'data': data},
    );
    return ControlRegistryDto.fromJson(response as JSON);
  }
}
