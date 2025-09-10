import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/character_model.dart';

class CharacterAvatar extends StatefulWidget {
  final CharacterModel character;
  final double size;
  final bool isAnimated;

  const CharacterAvatar({
    super.key,
    required this.character,
    this.size = 60,
    this.isAnimated = false,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _breathingController.repeat(reverse: true);
    
    // Random blinking
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    Future.delayed(Duration(seconds: 2 + (DateTime.now().millisecond % 3)), () {
      if (mounted && widget.isAnimated) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _scheduleNextBlink();
        });
      }
    });
  }

  @override
  void didUpdateWidget(CharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _startAnimations();
      } else {
        _breathingController.stop();
        _blinkController.stop();
      }
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _blinkController]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimated ? _breathingAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.character.color,
                  widget.character.color.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.character.color.withOpacity(0.4),
                  blurRadius: widget.isAnimated ? 15 : 10,
                  spreadRadius: widget.isAnimated ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Character Face
                Icon(
                  widget.character.id == 'nano' ? Icons.face_3 : Icons.face,
                  size: widget.size * 0.6,
                  color: Colors.white,
                ),
                
                // Blinking Eyes Overlay
                if (widget.isAnimated)
                  Positioned(
                    top: widget.size * 0.25,
                    child: Transform.scaleY(
                      scale: _blinkAnimation.value,
                      child: Container(
                        width: widget.size * 0.4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
