import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/character_model.dart';
import '../providers/character_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/gradient_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedCharacter = ref.watch(selectedCharacterProvider);
    
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.appTitle,
                          style: AppTheme.headingStyle.copyWith(fontSize: 28),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                        
                        Text(
                          localizations.welcomeSubtitle,
                          style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                        ).animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      ],
                    ),
                    
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    ).animate()
                      .fadeIn(delay: 400.ms)
                      .scale(begin: const Offset(0.5, 0.5)),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Character Selection Title
                Text(
                  localizations.selectCharacter,
                  style: AppTheme.headingStyle.copyWith(fontSize: 22),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Character Cards
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: Characters.all.length,
                    itemBuilder: (context, index) {
                      final character = Characters.all[index];
                      final isSelected = selectedCharacter?.id == character.id;
                      
                      return CharacterCard(
                        character: character,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedCharacterProvider.notifier).selectCharacter(character);
                        },
                      ).animate()
                        .fadeIn(delay: (800 + index * 200).ms, duration: 600.ms)
                        .slideY(begin: 0.5, end: 0)
                        .scale(begin: const Offset(0.8, 0.8));
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Start Chat Button
                if (selectedCharacter != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'بدء المحادثة مع ${selectedCharacter.getDisplayName(true)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 1200.ms, duration: 600.ms)
                    .slideY(begin: 0.5, end: 0)
                    .scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
