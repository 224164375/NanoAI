import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/voice_provider.dart';

class VoiceSettingsDialog extends ConsumerStatefulWidget {
  const VoiceSettingsDialog({super.key});

  @override
  ConsumerState<VoiceSettingsDialog> createState() => _VoiceSettingsDialogState();
}

class _VoiceSettingsDialogState extends ConsumerState<VoiceSettingsDialog> {
  late double _speechRate;
  late double _pitch;
  late double _volume;

  @override
  void initState() {
    super.initState();
    final voiceNotifier = ref.read(voiceProvider.notifier);
    _speechRate = voiceNotifier.speechRate;
    _pitch = voiceNotifier.pitch;
    _volume = voiceNotifier.volume;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعدادات الصوت', style: TextStyle(fontFamily: 'Cairo')),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlider(
              'سرعة الكلام',
              _speechRate,
              0.1,
              2.0,
              (value) {
                setState(() => _speechRate = value);
                ref.read(voiceProvider.notifier).setSpeechRate(value);
              },
            ),
            const SizedBox(height: 16),
            _buildSlider(
              'طبقة الصوت',
              _pitch,
              0.5,
              2.0,
              (value) {
                setState(() => _pitch = value);
                ref.read(voiceProvider.notifier).setPitch(value);
              },
            ),
            const SizedBox(height: 16),
            _buildSlider(
              'مستوى الصوت',
              _volume,
              0.0,
              1.0,
              (value) {
                setState(() => _volume = value);
                ref.read(voiceProvider.notifier).setVolume(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(voiceProvider.notifier).speak('هذا اختبار للإعدادات الجديدة');
          },
          child: const Text('اختبار'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value * 100).toInt()}%',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
