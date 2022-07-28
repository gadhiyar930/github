import 'package:flutter/material.dart';
import 'package:permission_asker/permission_asker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission asker demo',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission asker demo'),
      ),
      body: PermissionAskerBuilder(
        permissions: [
          Permission.location,
          Permission.camera,
        ],
        grantedBuilder: (context) => Center(
          child: Text('All permissions granted!'),
        ),
        notGrantedBuilder: (context, notGrantedPermissions) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Not granted permissions:'),
              for (final p in notGrantedPermissions) Text(p.toString())
            ],
          ),
        ),
        notGrantedListener: (notGrantedPermissions) =>
            print('Not granted:\n$notGrantedPermissions'),
      ),
    );
  }
}
