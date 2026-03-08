import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class ScannerService {
  final ImagePicker _imagePicker = ImagePicker();
  
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw Exception('Failed to get cameras: $e');
    }
  }
  
  Future<XFile?> captureImage() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Camera capture failed: $e');
    }
  }
  
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Gallery pick failed: $e');
    }
  }
  
  Future<File?> convertToFile(XFile xFile) async {
    try {
      return File(xFile.path);
    } catch (e) {
      throw Exception('File conversion failed: $e');
    }
  }
}