# NanoAI Flutter - مساعدك الذكي

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.16.0-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Arabic%20%7C%20English-orange" alt="Language">
  <img src="https://img.shields.io/badge/AI-Gemini%20%7C%20Local-purple" alt="AI">
</div>

## 🤖 About NanoAI

NanoAI is a complete Flutter rebuild of the original React Native application, featuring intelligent AI assistants with full Arabic RTL support, voice interaction, and animated characters. This version is optimized for deployment on free platforms like AppFlow, Netlify, Firebase, and Vercel.

### ✨ Key Features

- **🎭 AI Characters**: Interactive Nano (anime girl) and Naruto (anime boy) assistants
- **🗣️ Voice Interaction**: Full speech-to-text and text-to-speech in Arabic and English
- **🌐 RTL Support**: Complete Arabic localization with right-to-left layout
- **🎨 Modern UI**: Gradient backgrounds, smooth animations, and responsive design
- **💾 Local Storage**: Hive database for offline conversation management
- **🔄 Multiple AI Modes**: Local (offline), Connected (Gemini API), and Hybrid modes
- **📱 Cross-Platform**: Android APK, iOS, and Progressive Web App

## 🚀 Quick Start

### Option 1: One-Click Deploy (Recommended)
```bash
# Run the automated deployment script
ONE_CLICK_DEPLOY.bat
```

### Option 2: Manual Build
```bash
# Install dependencies
flutter pub get

# Build APK
flutter build apk --release

# Build Web
flutter build web --release
```

## 📦 Deployment Options

### 🌐 Free Web Hosting

1. **Netlify Drop** (Instant)
   - Run `ONE_CLICK_DEPLOY.bat`
   - Drag `NanoAI-Netlify-Deploy.zip` to [netlify.com/drop](https://app.netlify.com/drop)
   - Get instant live URL!

2. **GitHub Pages**
   - Push to GitHub repository
   - Enable Pages in repository settings
   - Auto-deploys via GitHub Actions

3. **Firebase Hosting**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   firebase deploy
   ```

4. **Vercel**
   ```bash
   npm install -g vercel
   vercel --prod
   ```

### 📱 Android Installation

1. **Direct APK Install**
   - Run `ONE_CLICK_DEPLOY.bat`
   - Transfer `NanoAI-Ready-Install.apk` to Android device
   - Enable "Unknown Sources" in settings
   - Install APK

2. **Google Play Console** (Future)
   - Upload signed APK bundle
   - Follow Play Store guidelines

## 🏗️ Project Structure

```
flutter_nanoai/
├── lib/
│   ├── core/
│   │   ├── services/          # AI, Voice, Database services
│   │   ├── models/            # Data models and adapters
│   │   ├── theme/             # App theming and styles
│   │   └── localization/      # Arabic/English translations
│   └── presentation/
│       ├── screens/           # Main app screens
│       ├── widgets/           # Reusable UI components
│       └── providers/         # State management (Riverpod)
├── android/                   # Android-specific configuration
├── web/                       # Web deployment files
├── assets/                    # Images, fonts, animations
└── build_scripts/             # Automated deployment scripts
```

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.16.0+
- Dart 3.0+
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation
```bash
# Clone repository
git clone [repository-url]
cd flutter_nanoai

# Install dependencies
flutter pub get

# Generate code (Hive adapters)
flutter packages pub run build_runner build

# Run on device/emulator
flutter run
```

### Environment Configuration

1. **Google Gemini API** (Optional)
   - Get API key from [Google AI Studio](https://makersuite.google.com/)
   - Add to app settings or environment variables

2. **MongoDB** (Optional)
   - Configure connection string in `DatabaseService`
   - Used for cloud synchronization

## 🎯 Features in Detail

### AI Characters

- **Nano**: Friendly anime girl assistant with pink theme
- **Naruto**: Energetic anime boy assistant with orange theme
- Each character has unique:
  - Voice parameters (pitch, rate, language)
  - Personality traits and responses
  - Visual animations and colors
  - Greeting messages and behaviors

### Voice Interaction

- **Speech Recognition**: Real-time Arabic and English recognition
- **Text-to-Speech**: Natural voice synthesis with character-specific settings
- **Voice Controls**: Push-to-talk and continuous listening modes
- **Audio Feedback**: Visual indicators for voice activity

### Localization

- **Arabic RTL**: Complete right-to-left layout support
- **Font Support**: Cairo and Tajawal fonts for Arabic text
- **Dynamic Switching**: Runtime language switching
- **Cultural Adaptation**: Arabic-specific UI patterns

### AI Modes

1. **Local Mode**: Offline responses using predefined patterns
2. **Connected Mode**: Google Gemini API integration
3. **Hybrid Mode**: Combines local and cloud AI intelligently

## 🔧 Configuration

### App Settings
- Language preference (Arabic/English)
- Theme mode (Light/Dark)
- Voice parameters (rate, pitch, volume)
- AI mode selection
- Character preferences

### Build Configuration
- Android: `android/app/build.gradle`
- iOS: `ios/Runner/Info.plist`
- Web: `web/index.html` and `web/manifest.json`

## 📊 Performance

- **APK Size**: ~15-20MB (optimized with obfuscation)
- **Web Bundle**: ~5-8MB (with tree shaking)
- **Memory Usage**: ~50-80MB runtime
- **Battery**: Optimized for mobile devices
- **Offline**: Full functionality without internet

## 🚀 Deployment Scripts

### Available Scripts

1. **`ONE_CLICK_DEPLOY.bat`**: Complete automated deployment
2. **`INSTANT_APK_BUILDER.bat`**: Quick APK generation
3. **`AUTO_DEPLOY_SCRIPT.bat`**: Multi-platform deployment
4. **GitHub Actions**: Automated CI/CD pipeline

### Build Outputs

- **Android**: `build/app/outputs/flutter-apk/`
- **Web**: `build/web/`
- **iOS**: `build/ios/iphoneos/`

## 🔒 Security & Privacy

- **Local Storage**: All conversations stored locally using Hive
- **API Keys**: Secure storage and optional cloud sync
- **Permissions**: Minimal required permissions (microphone, storage)
- **Privacy**: No data collection without user consent

## 🌟 Future Enhancements

- [ ] 3D character animations with Rive
- [ ] Advanced lip-sync for voice interaction
- [ ] Cloud conversation synchronization
- [ ] Plugin system for custom characters
- [ ] Advanced AI training capabilities
- [ ] Multi-language expansion

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Quick Help
- Run `ONE_CLICK_DEPLOY.bat` for automated setup
- Check `output/` folder for ready-to-use files
- Visit deployment platform websites for hosting

### Common Issues

1. **Flutter not found**: Run the deployment script to auto-install
2. **Build failures**: Ensure all dependencies are installed
3. **APK won't install**: Enable "Unknown Sources" on Android
4. **Voice not working**: Grant microphone permissions

### Contact
- GitHub Issues: [Create an issue](../../issues)
- Documentation: Check the `docs/` folder
- Community: Join our Discord server

---

<div align="center">
  <p>Made with ❤️ for the Arabic-speaking community</p>
  <p>🤖 NanoAI - Your Intelligent Assistant</p>
</div>
