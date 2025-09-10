import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App Title
  String get appTitle => locale.languageCode == 'ar' ? 'نانو الذكي' : 'NanoAI';

  // Navigation
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get chat => locale.languageCode == 'ar' ? 'المحادثة' : 'Chat';
  String get settings => locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  String get characters => locale.languageCode == 'ar' ? 'الشخصيات' : 'Characters';

  // Common Actions
  String get send => locale.languageCode == 'ar' ? 'إرسال' : 'Send';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
  String get delete => locale.languageCode == 'ar' ? 'حذف' : 'Delete';
  String get edit => locale.languageCode == 'ar' ? 'تعديل' : 'Edit';
  String get back => locale.languageCode == 'ar' ? 'رجوع' : 'Back';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get previous => locale.languageCode == 'ar' ? 'السابق' : 'Previous';
  String get done => locale.languageCode == 'ar' ? 'تم' : 'Done';
  String get ok => locale.languageCode == 'ar' ? 'موافق' : 'OK';
  String get yes => locale.languageCode == 'ar' ? 'نعم' : 'Yes';
  String get no => locale.languageCode == 'ar' ? 'لا' : 'No';

  // Chat Interface
  String get typeMessage => locale.languageCode == 'ar' ? 'اكتب رسالة...' : 'Type a message...';
  String get voiceInput => locale.languageCode == 'ar' ? 'الإدخال الصوتي' : 'Voice Input';
  String get listening => locale.languageCode == 'ar' ? 'أستمع...' : 'Listening...';
  String get speaking => locale.languageCode == 'ar' ? 'أتحدث...' : 'Speaking...';
  String get tapToSpeak => locale.languageCode == 'ar' ? 'اضغط للتحدث' : 'Tap to speak';
  String get releaseToSend => locale.languageCode == 'ar' ? 'اتركه للإرسال' : 'Release to send';

  // Character Selection
  String get selectCharacter => locale.languageCode == 'ar' ? 'اختر الشخصية' : 'Select Character';
  String get characterNano => locale.languageCode == 'ar' ? 'نانو' : 'Nano';
  String get characterNaruto => locale.languageCode == 'ar' ? 'ناروتو' : 'Naruto';
  String get nanoDescription => locale.languageCode == 'ar' 
      ? 'مساعدة ذكية ودودة ومفيدة تحب الدردشة والمساعدة في المهام المختلفة.'
      : 'A friendly and helpful AI assistant who loves to chat and help with various tasks.';
  String get narutoDescription => locale.languageCode == 'ar'
      ? 'مساعد ذكي نشيط وشجاع يشجع المستخدمين ويحب المغامرات.'
      : 'An energetic and brave AI assistant who encourages users and loves adventures.';

  // Settings
  String get language => locale.languageCode == 'ar' ? 'اللغة' : 'Language';
  String get theme => locale.languageCode == 'ar' ? 'المظهر' : 'Theme';
  String get voice => locale.languageCode == 'ar' ? 'الصوت' : 'Voice';
  String get aiMode => locale.languageCode == 'ar' ? 'وضع الذكاء الاصطناعي' : 'AI Mode';
  String get about => locale.languageCode == 'ar' ? 'حول التطبيق' : 'About';
  String get privacy => locale.languageCode == 'ar' ? 'الخصوصية' : 'Privacy';
  String get terms => locale.languageCode == 'ar' ? 'الشروط والأحكام' : 'Terms & Conditions';

  // AI Modes
  String get localMode => locale.languageCode == 'ar' ? 'الوضع المحلي' : 'Local Mode';
  String get connectedMode => locale.languageCode == 'ar' ? 'الوضع المتصل' : 'Connected Mode';
  String get hybridMode => locale.languageCode == 'ar' ? 'الوضع المختلط' : 'Hybrid Mode';
  String get localModeDesc => locale.languageCode == 'ar'
      ? 'يعمل بدون إنترنت مع ردود محفوظة مسبقاً'
      : 'Works offline with pre-saved responses';
  String get connectedModeDesc => locale.languageCode == 'ar'
      ? 'يستخدم الذكاء الاصطناعي المتقدم عبر الإنترنت'
      : 'Uses advanced AI through internet connection';
  String get hybridModeDesc => locale.languageCode == 'ar'
      ? 'يجمع بين الوضعين حسب توفر الإنترنت'
      : 'Combines both modes based on internet availability';

  // Voice Settings
  String get speechRate => locale.languageCode == 'ar' ? 'سرعة الكلام' : 'Speech Rate';
  String get pitch => locale.languageCode == 'ar' ? 'طبقة الصوت' : 'Pitch';
  String get volume => locale.languageCode == 'ar' ? 'مستوى الصوت' : 'Volume';
  String get testVoice => locale.languageCode == 'ar' ? 'اختبار الصوت' : 'Test Voice';

  // Theme Options
  String get lightTheme => locale.languageCode == 'ar' ? 'المظهر الفاتح' : 'Light Theme';
  String get darkTheme => locale.languageCode == 'ar' ? 'المظهر الداكن' : 'Dark Theme';
  String get systemTheme => locale.languageCode == 'ar' ? 'مظهر النظام' : 'System Theme';

  // Error Messages
  String get errorGeneral => locale.languageCode == 'ar' ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';
  String get errorNetwork => locale.languageCode == 'ar' ? 'خطأ في الاتصال بالإنترنت' : 'Network connection error';
  String get errorVoice => locale.languageCode == 'ar' ? 'خطأ في الخدمة الصوتية' : 'Voice service error';
  String get errorPermission => locale.languageCode == 'ar' ? 'الإذن مطلوب' : 'Permission required';
  String get errorMicrophone => locale.languageCode == 'ar' ? 'لا يمكن الوصول للميكروفون' : 'Cannot access microphone';

  // Success Messages
  String get settingsSaved => locale.languageCode == 'ar' ? 'تم حفظ الإعدادات' : 'Settings saved';
  String get messageSent => locale.languageCode == 'ar' ? 'تم إرسال الرسالة' : 'Message sent';
  String get voiceRecorded => locale.languageCode == 'ar' ? 'تم تسجيل الصوت' : 'Voice recorded';

  // Conversation Management
  String get newConversation => locale.languageCode == 'ar' ? 'محادثة جديدة' : 'New Conversation';
  String get conversationHistory => locale.languageCode == 'ar' ? 'سجل المحادثات' : 'Conversation History';
  String get clearHistory => locale.languageCode == 'ar' ? 'مسح السجل' : 'Clear History';
  String get deleteConversation => locale.languageCode == 'ar' ? 'حذف المحادثة' : 'Delete Conversation';
  String get confirmDelete => locale.languageCode == 'ar' ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?';

  // Welcome Messages
  String get welcomeTitle => locale.languageCode == 'ar' ? 'مرحباً بك في نانو الذكي' : 'Welcome to NanoAI';
  String get welcomeSubtitle => locale.languageCode == 'ar' 
      ? 'مساعدك الذكي مع الشخصيات التفاعلية'
      : 'Your smart assistant with interactive characters';
  String get getStarted => locale.languageCode == 'ar' ? 'ابدأ الآن' : 'Get Started';

  // API Configuration
  String get apiKey => locale.languageCode == 'ar' ? 'مفتاح API' : 'API Key';
  String get enterApiKey => locale.languageCode == 'ar' ? 'أدخل مفتاح API' : 'Enter API Key';
  String get apiKeyRequired => locale.languageCode == 'ar' ? 'مفتاح API مطلوب للوضع المتصل' : 'API Key required for connected mode';
  String get apiKeyInvalid => locale.languageCode == 'ar' ? 'مفتاح API غير صحيح' : 'Invalid API Key';

  // Time and Date
  String get today => locale.languageCode == 'ar' ? 'اليوم' : 'Today';
  String get yesterday => locale.languageCode == 'ar' ? 'أمس' : 'Yesterday';
  String get thisWeek => locale.languageCode == 'ar' ? 'هذا الأسبوع' : 'This Week';
  String get lastWeek => locale.languageCode == 'ar' ? 'الأسبوع الماضي' : 'Last Week';

  // Status Messages
  String get online => locale.languageCode == 'ar' ? 'متصل' : 'Online';
  String get offline => locale.languageCode == 'ar' ? 'غير متصل' : 'Offline';
  String get connecting => locale.languageCode == 'ar' ? 'جاري الاتصال...' : 'Connecting...';
  String get connected => locale.languageCode == 'ar' ? 'متصل' : 'Connected';
  String get disconnected => locale.languageCode == 'ar' ? 'منقطع' : 'Disconnected';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
