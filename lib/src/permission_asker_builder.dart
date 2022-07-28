import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_asker/src/permission_asker.dart';
import 'package:permission_asker/src/permission_data.dart';
import 'package:permission_handler/permission_handler.dart';

///A convenience widget that allows to build its content according to wether the supplied [permissions] are granted or not

class PermissionAskerBuilder extends StatefulWidget {
  ///[permissions] is the list of permissions that needs to be granted in order to use [grantedBuilder]
  final List<Permission> permissions;

  ///[grantedBuilder] builds the widget if all the supplied [permissions] are granted
  final WidgetBuilder grantedBuilder;

  ///[notGrantedBuilder] builds the widget if some of the supplied [permissions] are not granted
  final Widget Function(
          BuildContext context, List<PermissionData> permissionNotGrantedData)
      notGrantedBuilder;

  ///[notGrantedBuilder] builds the widget during the permissions asking process. By default a circular loader is built.
  final WidgetBuilder? loaderBuilder;

  ///[requestTimes] sets how many times each permission should be asked at max in a row
  final int? requestTimes;

  ///[notGrantedListener] is a listener triggered when some of the supplied [permissions] are not granted
  final void Function(List<PermissionData> permissionNotGrantedData)?
      notGrantedListener;

  const PermissionAskerBuilder({
    Key? key,
    required this.permissions,
    required this.grantedBuilder,
    required this.notGrantedBuilder,
    this.loaderBuilder,
    this.requestTimes,
    this.notGrantedListener,
  }) : super(key: key);

  @override
  _PermissionAskerBuilderState createState() => _PermissionAskerBuilderState();
}

class _PermissionAskerBuilderState extends State<PermissionAskerBuilder> {
  //The list is the list of PermissionData relative to permissions that are not granted
  final permissionsCompleter = Completer<List<PermissionData>>();
  late final permissionAsker = PermissionAsker(
    onPermissionData: onPermissionData,
    requestTimes: widget.requestTimes,
  );
  late final permissionsMap = {
    for (final permission in widget.permissions)
      permission: Completer<PermissionData>()
  };

  @override
  void initState() {
    super.initState();
    initPermissions();
    Future.wait(
      [for (final completer in permissionsMap.values) completer.future],
    ).then(
      (permissionDataList) => permissionsCompleter.complete([
        for (final permissionData in permissionDataList)
          if (!permissionData.status.isGranted) permissionData
      ]),
    );
  }

  Future<void> initPermissions() async {
    for (final permission in widget.permissions) {
      permissionAsker.askPermission(permission);
      await permissionsMap[permission]!.future;
    }
  }

  void onPermissionData(PermissionData permissionData) =>
      permissionsMap[permissionData.permission]?.complete(permissionData);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PermissionData>>(
      future: permissionsCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return widget.grantedBuilder(context);
          } else {
            final permissionsNotGranted = snapshot.data!;
            if (widget.notGrantedListener != null) {
              WidgetsBinding.instance?.addPostFrameCallback(
                (_) => widget.notGrantedListener!(permissionsNotGranted),
              );
            }
            return widget.notGrantedBuilder(context, snapshot.data!);
          }
        } else {
          return widget.loaderBuilder?.call(context) ??
              Center(
                child: CircularProgressIndicator(),
              );
        }
      },
    );
  }
}
