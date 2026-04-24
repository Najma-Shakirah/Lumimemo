import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../memories/memory.dart';

/// Handles all Firestore CRUD operations for user memories.
class MemoryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('memories');

  // ── Save a new memory ─────────────────────────────────────────────────────

  static Future<void> saveMemory({
    required String text,
    required String category,
  }) async {
    if (_uid == null || text.trim().isEmpty) return;
    await _col.add(Memory(
      id: '',
      userId: _uid!,
      text: text.trim(),
      category: category,
      emoji: Memory.emojiForCategory(category),
      createdAt: DateTime.now(),
    ).toMap());
  }

  // ── Save a batch of extracted memories ────────────────────────────────────

  static Future<void> saveBatch(List<Map<String, String>> memories) async {
    if (_uid == null) return;
    final batch = _db.batch();
    for (final m in memories) {
      final ref = _col.doc();
      final category = m['category'] ?? 'other';
      batch.set(ref, Memory(
        id: '',
        userId: _uid!,
        text: m['text'] ?? '',
        category: category,
        emoji: Memory.emojiForCategory(category),
        createdAt: DateTime.now(),
      ).toMap());
    }
    await batch.commit();
  }

  // ── Fetch all memories once ───────────────────────────────────────────────

  static Future<List<Memory>> getMemories() async {
    if (_uid == null) return [];
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map(Memory.fromFirestore).toList();
  }

  // ── Real-time stream ─────────────────────────────────────────────────────

  static Stream<List<Memory>> memoriesStream() {
    if (_uid == null) return const Stream.empty();
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Memory.fromFirestore).toList());
  }

  // ── Delete a memory ───────────────────────────────────────────────────────

  static Future<void> deleteMemory(String id) async {
    if (_uid == null) return;
    await _col.doc(id).delete();
  }

  // ── Get memories as a formatted context string for the AI ─────────────────

  static Future<String> getMemoryContext() async {
    final memories = await getMemories();
    if (memories.isEmpty) return 'No memories recorded yet.';
    return memories
        .take(30) // Keep context window manageable
        .map((m) => '• [${m.category}] ${m.text}')
        .join('\n');
  }
}
