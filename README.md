# permission_asker

A wrapper for [permission_handler](https://pub.dev/packages/permission_handler) which lifts some of the boilerplate needed to handle permissions in our apps.


## Why
Usually, when we need to build our widgets according to the permission status of a certain feature we need to check if the permission is granted or not and ask for it. 
Since these are async operations we usually need to add some boilerplate to do the right thing at the right time.

## What
In addition to everything that's provided with [permission_handler](https://pub.dev/packages/permission_handler) by exposing it, this package provides:

* a `PermissionAsker` class which allows to ask permissions and react to the results via the `onPermissionData` callback.
* a `PermissionAskerBuilder`class which allows to build a widget according to the status of a list of permissions

## Setup
Check [here](https://pub.dev/packages/permission_handler#setup) for setting up your permissions.

## Usage
Here's an example on how you can use the `PermissionAskerBuilder` widget
```dart
PermissionAskerBuilder(
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
            for (final p in notGrantedPermissions) 
              Text(p.toString())
        ],
      ),
  ),
  notGrantedListener: (notGrantedPermissions) => print('Not granted:\n$notGrantedPermissions'),
)
```
