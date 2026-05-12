import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
      return await _copyToScannerDirectory(File(xFile.path));
    } catch (e) {
      throw Exception('File conversion failed: $e');
    }
  }

  Future<File?> prepareFileForProcessing(File sourceFile) async {
    try {
      if (!await sourceFile.exists()) {
        return null;
      }

      if (_isScannerManagedFile(sourceFile)) {
        return sourceFile;
      }

      return await _copyToScannerDirectory(sourceFile);
    } catch (e) {
      throw Exception('File preparation failed: $e');
    }
  }

  bool _isScannerManagedFile(File file) {
    final normalizedPath = p.normalize(file.path);
    return normalizedPath.contains(
      '${p.separator}scanner_images${p.separator}',
    );
  }

  Future<File?> _copyToScannerDirectory(File sourceFile) async {
    if (!await sourceFile.exists()) {
      return null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final scannerDirectory = Directory(
      p.join(documentsDirectory.path, 'scanner_images'),
    );

    if (!await scannerDirectory.exists()) {
      await scannerDirectory.create(recursive: true);
    }

    final extension = p.extension(sourceFile.path);
    final safeExtension = extension.isNotEmpty ? extension : '.jpg';
    final fileName =
        'scan_${DateTime.now().microsecondsSinceEpoch}$safeExtension';
    final targetPath = p.join(scannerDirectory.path, fileName);

    return await sourceFile.copy(targetPath);
  }
}
