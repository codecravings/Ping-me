import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> isOverlayPermissionGranted() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  Future<bool> requestOverlayPermission() async {
    final bool? result = await FlutterOverlayWindow.requestPermission();
    return result ?? false;
  }

  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'overlay': await isOverlayPermissionGranted(),
      'notification': await isNotificationPermissionGranted(),
      'storage': await isStoragePermissionGranted(),
    };
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
