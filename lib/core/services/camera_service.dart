import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Service managing camera capture for employee attendance verification selfies.
class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Launches the camera (defaulting to front/selfie camera) and captures a photo.
  /// Returns `null` if the user cancels capture.
  Future<File?> takeSelfiePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1440,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('[CameraService] Error capturing photo: $e');
      return null;
    }
  }

  /// Launches camera or gallery to capture a receipt/document photo.
  /// Defaults to rear camera with high-clarity dimensions.
  Future<File?> takeDocumentPhoto({ImageSource source = ImageSource.camera}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('[CameraService] Error capturing document photo: $e');
      return null;
    }
  }

  /// Convenience method allowing explicit image source selection
  Future<File?> pickImage(ImageSource source) => takeDocumentPhoto(source: source);
}
