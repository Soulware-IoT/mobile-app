import 'package:cocina360/features/devices/data/services/device_remote_service.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteService remoteService;
  final NetworkChecker connectionChecker;

  DeviceRepositoryImpl(this.remoteService, this.connectionChecker);

  @override
  Future<List<IotDevice>> getDevices(String organizationId) async {
    await _requireConnection();
    final dtos = await remoteService.getDevices(organizationId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<IotDevice> getDevice(String organizationId, String deviceId) async {
    await _requireConnection();
    final dto = await remoteService.getDevice(organizationId, deviceId);
    return dto.toDomain();
  }

  @override
  Future<EdgeDevice?> getEdgeDevice(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.getEdgeDevice(organizationId);
    return dto?.toDomain();
  }

  Future<void> _requireConnection() async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }
  }
}
