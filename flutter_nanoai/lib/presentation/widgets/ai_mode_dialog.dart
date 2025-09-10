import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/app_theme.dart';

class AIModeDialog extends ConsumerStatefulWidget {
  const AIModeDialog({super.key});

  @override
  ConsumerState<AIModeDialog> createState() => _AIModeDialogState();
}

class _AIModeDialogState extends ConsumerState<AIModeDialog> {
  AIMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = AIService.instance.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    final aiModes = AIService.instance.getAIModes();

    return AlertDialog(
      title: const Text('وضع الذكاء الاصطناعي', style: TextStyle(fontFamily: 'Cairo')),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: aiModes.entries.map((entry) {
            final mode = entry.key;
            final info = entry.value;
            
            return RadioListTile<AIMode>(
              value: mode,
              groupValue: _selectedMode,
              onChanged: (value) {
                setState(() => _selectedMode = value);
              },
              title: Text(
                info['name']!,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                info['description']!,
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              activeColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_selectedMode != null) {
              await AIService.instance.setAIMode(_selectedMode!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تغيير وضع الذكاء الاصطناعي')),
              );
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
