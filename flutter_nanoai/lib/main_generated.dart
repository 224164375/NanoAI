// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/message_model.dart';
import 'core/models/message_adapter.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(ConversationAdapter());
}
