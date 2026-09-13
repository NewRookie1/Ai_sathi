import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AudioService {
  static const _uuid = Uuid();
  String? _currentRecordingPath;

  Future<String> getRecordingPath() async {
    final directory = await getTemporaryDirectory();
    final id = _uuid.v4();
    _currentRecordingPath = '${directory.path}/recording_$id.wav';
    return _currentRecordingPath!;
  }

  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> clearRecording() async {
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
    }
  }

  Future<int> getRecordingDuration(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final bytes = await file.length();
    return (bytes ~/ (16000 * 2));
  }

  bool isValidRecording(String path) {
    return path.isNotEmpty && (path.endsWith('.wav') || path.endsWith('.m4a'));
  }
}
