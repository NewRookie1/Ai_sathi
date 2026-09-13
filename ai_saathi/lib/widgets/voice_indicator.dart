import 'package:flutter/material.dart';
import '../core/config/theme.dart';

class VoiceIndicator extends StatelessWidget {
  final bool isRecording;
  final int duration;

  const VoiceIndicator({
    super.key,
    required this.isRecording,
    this.duration = 0,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRecording) ...[
          _buildPulseIndicator(),
          const SizedBox(width: 12),
        ],
        Text(
          '$minutes:$seconds',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isRecording ? Colors.red : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseIndicator() {
    return Row(
      children: List.generate(5, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + index * 100),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: isRecording ? 20 + (index * 4).toDouble() : 8,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
