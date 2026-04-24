import 'package:cloud_firestore/cloud_firestore.dart';

/// A single memory extracted from a conversation with the AI companion.
class Memory {
  final String id;
  final String userId;
  final String text;      // e.g. "Loves gardening, especially roses"
  final String category;  // e.g. 'hobby', 'family', 'place', 'food', 'event', 'other'
  final String emoji;     // Quick visual indicator
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.userId,
    required this.text,
    required this.category,
    required this.emoji,
    required this.createdAt,
  });

  factory Memory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Memory(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      category: data['category'] ?? 'other',
      emoji: data['emoji'] ?? '💭',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'text': text,
        'category': category,
        'emoji': emoji,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Emoji map for categories
  static String emojiForCategory(String category) {
    switch (category) {
      case 'family':   return '👨‍👩‍👧';
      case 'hobby':    return '🎨';
      case 'place':    return '🏡';
      case 'food':     return '🍽️';
      case 'event':    return '🎉';
      case 'health':   return '❤️';
      case 'pet':      return '🐾';
      case 'work':     return '💼';
      default:         return '💭';
    }
  }
}
