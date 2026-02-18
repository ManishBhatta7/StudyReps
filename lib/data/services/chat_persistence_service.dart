import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persistent chat message model
class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final String? videoId; // Which video this message belongs to
  final String? imageBase64; // Base64 image data (thumbnail only, for display)
  final String? imageMimeType; // e.g. 'image/jpeg', 'image/png'

  ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.videoId,
    this.imageBase64,
    this.imageMimeType,
  });

  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isBot': isBot,
        'timestamp': timestamp.toIso8601String(),
        'videoId': videoId,
        if (imageBase64 != null) 'imageBase64': imageBase64,
        if (imageMimeType != null) 'imageMimeType': imageMimeType,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isBot: json['isBot'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        videoId: json['videoId'] as String?,
        imageBase64: json['imageBase64'] as String?,
        imageMimeType: json['imageMimeType'] as String?,
      );
}

/// Persistent Chat Service
///
/// Stores conversation history per video using Hive.
/// Supports:
/// - Per-video conversation threads
/// - Cross-session memory (conversations survive app restarts)
/// - Global learning context (what topics user has struggled with)
/// - Conversation summarization for long threads
class ChatPersistenceService {
  static const String _boxName = 'tutorbot_chats';
  static const String _contextBoxName = 'tutorbot_context';
  static const int _maxMessagesPerVideo = 100;
  static const int _contextWindowSize = 20; // Messages to include in AI context

  static Box? _chatBox;
  static Box? _contextBox;

  /// Initialize storage (call once at app startup)
  static Future<void> init() async {
    try {
      _chatBox = await Hive.openBox(_boxName);
      _contextBox = await Hive.openBox(_contextBoxName);
      debugPrint('💾 ChatPersistenceService initialized');
    } catch (e) {
      debugPrint('⚠️ ChatPersistenceService init error: $e');
    }
  }

  /// Get all messages for a specific video
  static List<ChatMessage> getMessagesForVideo(String videoId) {
    if (_chatBox == null) return [];
    try {
      final raw = _chatBox!.get('chat_$videoId');
      if (raw == null) return [];

      final List<dynamic> decoded = jsonDecode(raw as String);
      return decoded
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('⚠️ Error loading messages for $videoId: $e');
      return [];
    }
  }

  /// Save a message to a video's conversation
  static Future<void> saveMessage(String videoId, ChatMessage message) async {
    if (_chatBox == null) return;
    try {
      final existing = getMessagesForVideo(videoId);
      existing.add(message);

      // Trim to max messages (keep most recent)
      final trimmed = existing.length > _maxMessagesPerVideo
          ? existing.sublist(existing.length - _maxMessagesPerVideo)
          : existing;

      await _chatBox!.put(
        'chat_$videoId',
        jsonEncode(trimmed.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('⚠️ Error saving message: $e');
    }
  }

  /// Get recent messages for AI context window
  static List<ChatMessage> getContextWindow(String videoId) {
    final messages = getMessagesForVideo(videoId);
    if (messages.length <= _contextWindowSize) return messages;
    return messages.sublist(messages.length - _contextWindowSize);
  }

  /// Clear conversation for a video
  static Future<void> clearVideoChat(String videoId) async {
    if (_chatBox == null) return;
    await _chatBox!.delete('chat_$videoId');
  }

  /// Get all video IDs that have conversations
  static List<String> getConversationVideoIds() {
    if (_chatBox == null) return [];
    return _chatBox!.keys
        .where((k) => k.toString().startsWith('chat_'))
        .map((k) => k.toString().replaceFirst('chat_', ''))
        .toList();
  }

  // ── Global Learning Context ──
  // Tracks topics the user struggles with across all videos

  /// Record a topic the user struggled with
  static Future<void> recordStruggleTopic(String topic, String videoId) async {
    if (_contextBox == null) return;
    try {
      final raw = _contextBox!.get('struggle_topics') as String?;
      final Map<String, dynamic> topics =
          raw != null ? jsonDecode(raw) : {};

      topics[topic] = {
        'count': ((topics[topic]?['count'] as int?) ?? 0) + 1,
        'lastVideoId': videoId,
        'lastSeen': DateTime.now().toIso8601String(),
      };

      await _contextBox!.put('struggle_topics', jsonEncode(topics));
    } catch (e) {
      debugPrint('⚠️ Error recording struggle topic: $e');
    }
  }

  /// Get topics the user has struggled with
  static Map<String, dynamic> getStruggleTopics() {
    if (_contextBox == null) return {};
    try {
      final raw = _contextBox!.get('struggle_topics') as String?;
      return raw != null ? jsonDecode(raw) : {};
    } catch (_) {
      return {};
    }
  }

  /// Save a learning summary for a video (generated by AI after conversation)
  static Future<void> saveLearnerProfile(String key, String value) async {
    if (_contextBox == null) return;
    await _contextBox!.put('profile_$key', value);
  }

  /// Get a learner profile value
  static String? getLearnerProfile(String key) {
    if (_contextBox == null) return null;
    return _contextBox!.get('profile_$key') as String?;
  }
}
