import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/character_model.dart';
import '../../core/localization/app_localizations.dart';

class CharacterCard extends StatefulWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isArabic = localizations.locale.languageCode == 'ar';

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.character.color,
                          widget.character.color.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? widget.character.color.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: widget.isSelected ? 20 : 10,
                    spreadRadius: widget.isSelected ? 2 : 0,
                    offset: const Offset(0, 5),
                  ),
                  if (widget.isSelected)
                    BoxShadow(
                      color: widget.character.color.withOpacity(0.2 * _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Character Avatar
                    Container(
                      width: 80,
                      height: 80,
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
                            color: widget.character.color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.character.id == 'nano'
                            ? Icons.face_3
                            : Icons.face,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate()
                      .scale(delay: 100.ms, duration: 300.ms)
                      .then()
                      .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),

                    const SizedBox(height: 16),

                    // Character Name
                    Text(
                      widget.character.getDisplayName(isArabic),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isSelected ? Colors.white : widget.character.color,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Character Description
                    Text(
                      widget.character.getDescription(isArabic),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isSelected 
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Selection Indicator
                    if (widget.isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isArabic ? 'مختار' : 'Selected',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(duration: 300.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
