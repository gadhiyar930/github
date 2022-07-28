import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionData {
  final Permission permission;
  final PermissionStatus status;
  final ServiceStatus serviceStatus;
  PermissionData(this.permission, this.status,
      [this.serviceStatus = ServiceStatus.notApplicable]);

  @override
  String toString() =>
      'Permission: ${describeEnum(permission)} - Status: ${describeEnum(status)} - ServiceStatus: ${describeEnum(serviceStatus)}';
}
