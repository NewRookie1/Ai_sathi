import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<void> initializeCameras() async {
    _cameras = await availableCameras();
  }

  Future<void> initializeCamera({
    ResolutionPreset resolution = ResolutionPreset.medium,
    bool enableAudio = false,
  }) async {
    if (_cameras.isEmpty) {
      await initializeCameras();
    }
    if (_cameras.isEmpty) return;

    _controller = CameraController(
      _cameras.first,
      resolution,
      enableAudio: enableAudio,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  Future<String> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final xFile = await _controller!.takePicture();
    final compressedPath = await _compressImage(xFile.path);
    return compressedPath;
  }

  Future<String> _compressImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return imagePath;

    var resized = image;
    if (image.width > AppConstants.maxImageWidth ||
        image.height > AppConstants.maxImageHeight) {
      resized = img.copyResize(
        image,
        width: image.width > AppConstants.maxImageWidth
            ? AppConstants.maxImageWidth
            : null,
        height: image.height > AppConstants.maxImageHeight
            ? AppConstants.maxImageHeight
            : null,
        maintainAspect: true,
      );
    }

    final directory = await getTemporaryDirectory();
    final id = const Uuid().v4();
    final outputPath = '${directory.path}/product_$id.jpg';
    await File(outputPath).writeAsBytes(
      img.encodeJpg(resized, quality: AppConstants.imageQuality),
    );

    return outputPath;
  }

  Future<String> compressForUpload(String imagePath) async {
    final file = File(imagePath);
    final size = await file.length();

    if (size <= AppConstants.maxImageSizeBytes) {
      return imagePath;
    }

    return _compressImage(imagePath);
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    final currentCameraIndex = _cameras.indexOf(_controller!.description);
    final newCameraIndex = (currentCameraIndex + 1) % _cameras.length;

    await _controller?.dispose();
    _controller = CameraController(
      _cameras[newCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
