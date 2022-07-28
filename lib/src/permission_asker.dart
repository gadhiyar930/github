import 'package:pedantic/pedantic.dart';
import 'package:permission_asker/src/permission_data.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionAsker {
  /// Maximum number of times the request should be repeated in a row
  final int _requestTimes;

  /// This is called when a permission has a status which is not granted nor denied
  final void Function(PermissionData)? _onPermissionData;

  ///Set [requestTimes] to 0 to request repeatedly a permission
  /// [onGranted] is called when a permission is granted
  /// [onDenied] is called when a permission is denied
  /// [onPermissionData] is called when there's a result for the asking process
  PermissionAsker({
    int? requestTimes,
    required void Function(PermissionData) onPermissionData,
  })   : _requestTimes = requestTimes ?? 1,
        _onPermissionData = onPermissionData;

  Future<void> _checkPermission(
    Permission permission, {
    required PermissionStatus status,
    required ServiceStatus serviceStatus,
    int counter = 0,
  }) async {
    if (serviceStatus.isDisabled) {
      _onPermissionData?.call(
        PermissionData(permission, status, serviceStatus),
      );
    }

    if (status.isDenied && (_requestTimes == 0 || counter <= _requestTimes)) {
      unawaited(_askPermission(permission, counter + 1));
      return;
    }

    final permissionData = PermissionData(permission, status, serviceStatus);
    _onPermissionData?.call(permissionData);
  }

  Future<void> _askPermission(Permission permission, int counter) async {
    ServiceStatus? serviceStatus;
    if (permission is PermissionWithService) {
      serviceStatus = await permission.serviceStatus;
    }
    final status = await permission.request();
    unawaited(
      _checkPermission(
        permission,
        status: status,
        serviceStatus: serviceStatus ?? ServiceStatus.notApplicable,
        counter: counter,
      ),
    );
  }

  ///Call this method to ask a permission
  void askPermission(Permission permission) => _askPermission(permission, 0);
}
