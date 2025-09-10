import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/message_model.dart';
import '../../core/models/character_model.dart';
import '../../core/localization/app_localizations.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final CharacterModel character;
  final Function(String)? onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    required this.character,
    this.onSpeak,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPressed = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الرسالة'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isUser = widget.message.isUser;
    final isArabic = localizations.locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Character Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.character.color,
                    widget.character.color.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.character.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.character.id == 'nano' ? Icons.face_3 : Icons.face,
                size: 18,
                color: Colors.white,
              ),
            ).animate()
              .scale(delay: 100.ms, duration: 300.ms)
              .then()
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 8),
          ],

          // Message Bubble
          Flexible(
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onLongPress: _copyToClipboard,
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey[50]!,
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppTheme.primaryColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Content
                      Text(
                        widget.message.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: isUser ? Colors.white : Colors.black87,
                          fontFamily: 'Tajawal',
                          height: 1.4,
                        ),
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      ),

                      const SizedBox(height: 8),

                      // Message Footer
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Timestamp
                          Text(
                            _formatTime(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isUser 
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[600],
                              fontFamily: 'Tajawal',
                            ),
                          ),

                          if (!isUser) ...[
                            const SizedBox(width: 8),
                            // Speak Button
                            GestureDetector(
                              onTap: () => widget.onSpeak?.call(widget.message.content),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.character.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 16,
                                  color: widget.character.color,
                                ),
                              ),
                            ),
                          ],

                          if (isUser) ...[
                            const SizedBox(width: 8),
                            // Message Status
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} د';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} س';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
