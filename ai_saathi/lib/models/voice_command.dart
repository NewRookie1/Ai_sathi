class VoiceCommand {
  final String id;
  final String audioPath;
  final String? transcript;
  final String? detectedLanguage;
  final String? normalizedText;
  final double confidence;
  final DateTime recordedAt;

  VoiceCommand({
    required this.id,
    required this.audioPath,
    this.transcript,
    this.detectedLanguage,
    this.normalizedText,
    this.confidence = 0,
    required this.recordedAt,
  });

  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      id: json['id'],
      audioPath: json['audio_path'],
      transcript: json['transcript'],
      detectedLanguage: json['detected_language'],
      normalizedText: json['normalized_text'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audio_path': audioPath,
      'transcript': transcript,
      'detected_language': detectedLanguage,
      'normalized_text': normalizedText,
      'confidence': confidence,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  VoiceCommand copyWith({
    String? transcript,
    String? detectedLanguage,
    String? normalizedText,
    double? confidence,
  }) {
    return VoiceCommand(
      id: id,
      audioPath: audioPath,
      transcript: transcript ?? this.transcript,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      normalizedText: normalizedText ?? this.normalizedText,
      confidence: confidence ?? this.confidence,
      recordedAt: recordedAt,
    );
  }
}
