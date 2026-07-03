import 'package:cocina360/features/devices/data/services/device_remote_service.dart';
import 'package:cocina360/features/devices/domain/model/device_quota.dart';
import 'package:cocina360/features/devices/domain/model/devices_inventory.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteService remoteService;
  final NetworkChecker connectionChecker;

  DeviceRepositoryImpl(this.remoteService, this.connectionChecker);

  @override
  Future<DevicesInventory> getDevices(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.getDevices(organizationId);
    return DevicesInventory(
      devices: dto.devices.map((d) => d.toDomain()).toList(),
      quota: dto.quotaUsed != null && dto.quotaLimit != null
          ? DeviceQuota(used: dto.quotaUsed!, limit: dto.quotaLimit!)
          : null,
    );
  }

  @override
  Future<IotDevice> getDevice(String deviceId) async {
    await _requireConnection();
    final dto = await remoteService.getDevice(deviceId);
    return dto.toDomain();
  }

  @override
  Future<IotDevice> updateDevice(
    String deviceId, {
    String? name,
    Thresholds? thresholds,
    bool? active,
  }) async {
    await _requireConnection();
    final dto = await remoteService.updateDevice(
      deviceId,
      name: name,
      thresholds: thresholds == null ? null : _thresholdsBody(thresholds),
      status: active == null ? null : (active ? 'ACTIVE' : 'INACTIVE'),
    );
    return dto.toDomain();
  }

  @override
  Future<EdgeDevice?> getEdgeDevice(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.getEdgeDevice(organizationId);
    return dto?.toDomain();
  }

  /// The backend requires all four values when thresholds are provided.
  Map<String, dynamic> _thresholdsBody(Thresholds t) => {
        'temperature': {
          'warn': t.warnTemperatureC,
          'crit': t.critTemperatureC,
        },
        'gas': {'warn': t.warnGasPpm, 'crit': t.critGasPpm},
      };

  Future<void> _requireConnection() async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }
  }
}
