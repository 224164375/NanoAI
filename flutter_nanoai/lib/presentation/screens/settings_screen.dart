import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/ai_service.dart';
import '../providers/app_state_provider.dart';
import '../providers/voice_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/settings_tile.dart';
import '../widgets/voice_settings_dialog.dart';
import '../widgets/ai_mode_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final appState = ref.watch(appStateProvider);
    final voiceState = ref.watch(voiceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          localizations.settings,
          style: AppTheme.headingStyle,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),

              // Language Settings
              _buildSettingsSection(
                localizations.language,
                [
                  SettingsTile(
                    icon: Icons.language,
                    title: localizations.language,
                    subtitle: appState.isArabic ? 'العربية' : 'English',
                    onTap: () => _showLanguageDialog(context, ref),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // Theme Settings
              _buildSettingsSection(
                localizations.theme,
                [
                  SettingsTile(
                    icon: Icons.palette,
                    title: localizations.theme,
                    subtitle: _getThemeName(appState.themeMode, localizations),
                    onTap: () => _showThemeDialog(context, ref),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // Voice Settings
              _buildSettingsSection(
                localizations.voice,
                [
                  SettingsTile(
                    icon: Icons.record_voice_over,
                    title: localizations.voice,
                    subtitle: 'سرعة: ${(voiceState.speechRate * 100).toInt()}%',
                    onTap: () => _showVoiceSettings(context, ref),
                  ),
                  SettingsTile(
                    icon: Icons.volume_up,
                    title: localizations.testVoice,
                    subtitle: 'اختبار الصوت الحالي',
                    onTap: () => _testVoice(ref),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // AI Settings
              _buildSettingsSection(
                localizations.aiMode,
                [
                  SettingsTile(
                    icon: Icons.psychology,
                    title: localizations.aiMode,
                    subtitle: _getAIModeName(AIService.instance.currentMode, localizations),
                    onTap: () => _showAIModeDialog(context, ref),
                  ),
                  SettingsTile(
                    icon: Icons.key,
                    title: localizations.apiKey,
                    subtitle: 'إعداد مفتاح Gemini API',
                    onTap: () => _showAPIKeyDialog(context, ref),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // App Info
              _buildSettingsSection(
                localizations.about,
                [
                  SettingsTile(
                    icon: Icons.info,
                    title: localizations.about,
                    subtitle: 'NanoAI v1.0.0',
                    onTap: () => _showAboutDialog(context, localizations),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip,
                    title: localizations.privacy,
                    subtitle: 'سياسة الخصوصية',
                    onTap: () => _showPrivacyDialog(context, localizations),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 1000.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: AppTheme.headingStyle.copyWith(fontSize: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _getThemeName(ThemeMode themeMode, AppLocalizations localizations) {
    switch (themeMode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  String _getAIModeName(AIMode mode, AppLocalizations localizations) {
    switch (mode) {
      case AIMode.local:
        return localizations.localMode;
      case AIMode.connected:
        return localizations.connectedMode;
      case AIMode.hybrid:
        return localizations.hybridMode;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇸🇦'),
              title: Text('العربية'),
              onTap: () {
                ref.read(appStateProvider.notifier).setLocale(const Locale('ar', 'SA'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇺🇸'),
              title: Text('English'),
              onTap: () {
                ref.read(appStateProvider.notifier).setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('المظهر الفاتح'),
              onTap: () {
                ref.read(appStateProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('المظهر الداكن'),
              onTap: () {
                ref.read(appStateProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.auto_mode),
              title: Text('مظهر النظام'),
              onTap: () {
                ref.read(appStateProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => VoiceSettingsDialog(),
    );
  }

  void _showAIModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AIModeDialog(),
    );
  }

  void _showAPIKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مفتاح Gemini API'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'أدخل مفتاح API',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              AIService.instance.setAPIKey(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حفظ مفتاح API')),
              );
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _testVoice(WidgetRef ref) {
    ref.read(voiceProvider.notifier).speak('مرحباً! هذا اختبار للصوت الحالي.');
  }

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حول التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NanoAI - مساعدك الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 8),
            Text('تطبيق مساعد ذكي مع شخصيات تفاعلية ودعم كامل للغة العربية.'),
            SizedBox(height: 16),
            Text('المطور: فريق NanoAI'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سياسة الخصوصية'),
        content: SingleChildScrollView(
          child: Text(
            'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.\n\n'
            '• لا نجمع أي بيانات شخصية بدون إذنك\n'
            '• المحادثات محفوظة محلياً على جهازك\n'
            '• لا نشارك بياناتك مع أطراف ثالثة\n'
            '• يمكنك حذف بياناتك في أي وقت\n\n'
            'للمزيد من المعلومات، يرجى زيارة موقعنا الإلكتروني.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}
