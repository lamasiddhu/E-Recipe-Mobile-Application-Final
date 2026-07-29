import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  static bool _locationRequestedThisSession = false;

  static Future<PermissionStatus> requestLocationOncePerSession() async {
    if (kIsWeb || _locationRequestedThisSession) {
      return Permission.locationWhenInUse.status;
    }
    _locationRequestedThisSession = true;
    return Permission.locationWhenInUse.request();
  }

  static Future<PermissionStatus> requestCamera() {
    return Permission.camera.request();
  }

  static Future<PermissionStatus> requestGallery() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return Permission.photos.request();
    }
    // Android's system Photo Picker does not require broad storage permission.
    return PermissionStatus.granted;
  }
}
