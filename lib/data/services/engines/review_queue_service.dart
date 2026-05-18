import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─── Status ──────────────────────────────────────────────────────────────────

enum ReviewStatus { pending, approved, rejected }

// ─── Item Type ───────────────────────────────────────────────────────────────

enum ReviewItemType { question, flashcard }

// ─── ReviewItem ──────────────────────────────────────────────────────────────

/// A single piece of AI-generated content sitting in the review queue.
/// Stored as JSON in Hive — no schema migrations needed.
class ReviewItem {
  final String id;
  final ReviewItemType type;
  final String videoId;
  final String videoTitle;
  final Map<String, dynamic> content; // Raw JSON from the engine
  ReviewStatus status;
  final DateTime createdAt;
  DateTime? reviewedAt;
  String? reviewNote; // Editor's note when approving/rejecting

  ReviewItem({
    required this.id,
    required this.type,
    required this.videoId,
    required this.videoTitle,
    required this.content,
    this.status = ReviewStatus.pending,
    required this.createdAt,
    this.reviewedAt,
    this.reviewNote,
  });

  factory ReviewItem.question({
    required String videoId,
    required String videoTitle,
    required dynamic content, // GeneratedQuestion
  }) {
    return ReviewItem(
      id: '${videoId}_q_${DateTime.now().microsecondsSinceEpoch}',
      type: ReviewItemType.question,
      videoId: videoId,
      videoTitle: videoTitle,
      content: content.toJson(),
      createdAt: DateTime.now(),
    );
  }

  factory ReviewItem.flashcard({
    required String videoId,
    required String videoTitle,
    required dynamic content, // GeneratedFlashcard
  }) {
    return ReviewItem(
      id: '${videoId}_fc_${DateTime.now().microsecondsSinceEpoch}',
      type: ReviewItemType.flashcard,
      videoId: videoId,
      videoTitle: videoTitle,
      content: content.toJson(),
      createdAt: DateTime.now(),
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'videoId': videoId,
    'videoTitle': videoTitle,
    'content': content,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewNote': reviewNote,
  };

  factory ReviewItem.fromJson(Map<String, dynamic> j) {
    return ReviewItem(
      id: j['id'] ?? '',
      type: ReviewItemType.values.firstWhere(
        (e) => e.name == j['type'],
        orElse: () => ReviewItemType.question,
      ),
      videoId: j['videoId'] ?? '',
      videoTitle: j['videoTitle'] ?? '',
      content: Map<String, dynamic>.from(j['content'] ?? {}),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == j['status'],
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      reviewedAt: j['reviewedAt'] != null ? DateTime.tryParse(j['reviewedAt']) : null,
      reviewNote: j['reviewNote'],
    );
  }

  // ── Convenience getters ───────────────────────────────────────────────────

  String get displayPrompt {
    if (type == ReviewItemType.question) return content['prompt'] ?? 'No prompt';
    if (type == ReviewItemType.flashcard) return content['front'] ?? 'No front';
    return '';
  }

  String get displayAnswer {
    if (type == ReviewItemType.question) return content['correct_answer'] ?? '';
    if (type == ReviewItemType.flashcard) return content['back'] ?? '';
    return '';
  }

  String get bloomLevel => content['bloom_level'] ?? '';
  String get cardLabel => content['label'] ?? '';
  String get explanation => content['explanation'] ?? content['memory_hook'] ?? '';
  String get difficulty {
    final d = content['difficulty'];
    if (d is int) return ['easy', 'medium', 'hard'][d.clamp(1, 3) - 1];
    return d?.toString() ?? 'medium';
  }
}

// ─── ReviewQueueService ───────────────────────────────────────────────────────

/// Local Hive-backed queue for AI-generated content pending human review.
///
/// Workflow:
///   Engine generates → [addAll] → items are PENDING
///   Reviewer sees items in ReviewScreen → approves/rejects
///   Feed/Drill/Quiz queries [getApproved] to build content
class ReviewQueueService {
  static const String _boxName = 'content_review_queue';
  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    debugPrint('📋 ReviewQueue: initialized (${_box!.length} items)');
  }

  static Box<String> get _store {
    assert(_box != null, 'Call ReviewQueueService.init() before use');
    return _box!;
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  static Future<void> addAll(List<ReviewItem> items) async {
    for (final item in items) {
      await _store.put(item.id, jsonEncode(item.toJson()));
    }
  }

  static Future<void> updateItem(ReviewItem item) async {
    await _store.put(item.id, jsonEncode(item.toJson()));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  static List<ReviewItem> getAll() {
    return _store.values
        .map((s) => ReviewItem.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<ReviewItem> getPending() =>
      getAll().where((i) => i.status == ReviewStatus.pending).toList();

  static List<ReviewItem> getApproved({
    required String videoId,
    ReviewItemType? type,
  }) {
    return getAll().where((i) {
      return i.videoId == videoId &&
          i.status == ReviewStatus.approved &&
          (type == null || i.type == type);
    }).toList();
  }

  static List<ReviewItem> getAllApproved({ReviewItemType? type}) {
    return getAll().where((i) {
      return i.status == ReviewStatus.approved &&
          (type == null || i.type == type);
    }).toList();
  }

  // ── Review actions ─────────────────────────────────────────────────────────

  static Future<void> approve(String id, {String? note}) async {
    final items = getAll();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = items[idx]
      ..status = ReviewStatus.approved
      ..reviewedAt = DateTime.now()
      ..reviewNote = note;
    await updateItem(item);
  }

  static Future<void> reject(String id, {String? note}) async {
    final items = getAll();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = items[idx]
      ..status = ReviewStatus.rejected
      ..reviewedAt = DateTime.now()
      ..reviewNote = note;
    await updateItem(item);
  }

  static Future<void> delete(String id) async {
    await _store.delete(id);
  }

  static Future<void> clearAll() async {
    await _store.clear();
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  static Map<String, int> get stats {
    final all = getAll();
    return {
      'total': all.length,
      'pending': all.where((i) => i.status == ReviewStatus.pending).length,
      'approved': all.where((i) => i.status == ReviewStatus.approved).length,
      'rejected': all.where((i) => i.status == ReviewStatus.rejected).length,
    };
  }
}
