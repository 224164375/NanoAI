import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/character_model.dart';
import '../providers/voice_provider.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  final Function(String) onResult;
  final CharacterModel character;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    required this.character,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleVoiceInput() async {
    final voiceNotifier = ref.read(voiceProvider.notifier);
    final voiceState = ref.read(voiceProvider);

    if (voiceState.isListening) {
      await voiceNotifier.stopListening();
      _pulseController.stop();
    } else {
      await voiceNotifier.startListening(localeId: 'ar-SA');
      if (ref.read(voiceProvider).isListening) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);

    // Listen for voice results
    ref.listen<VoiceState>(voiceProvider, (previous, next) {
      if (next.lastRecognizedText != null && next.lastRecognizedText!.isNotEmpty) {
        final text = ref.read(voiceProvider.notifier).consumeRecognizedText();
        if (text != null) {
          widget.onResult(text);
        }
      }
    });

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: _handleVoiceInput,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: voiceState.isListening
                    ? LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.red.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          widget.character.color,
                          widget.character.color.withOpacity(0.8),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: voiceState.isListening
                        ? Colors.red.withOpacity(0.4)
                        : widget.character.color.withOpacity(0.4),
                    blurRadius: voiceState.isListening ? 20 : 10,
                    spreadRadius: voiceState.isListening ? 2 : 0,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: voiceState.isListening ? _pulseAnimation.value : 1.0,
                child: Icon(
                  voiceState.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8));
  }
}
