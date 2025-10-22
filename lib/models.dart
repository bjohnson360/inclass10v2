class FolderModel {
  final int? id;
  final String name;           // hearts, spades, diamonds, clubs
  final String? previewImage;  // first card image
  final DateTime createdAt;

  FolderModel({
    this.id,
    required this.name,
    this.previewImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'previewImage': previewImage,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FolderModel.fromMap(Map<String, dynamic> m) => FolderModel(
    id: m['id'] as int?,
    name: m['name'] as String,
    previewImage: m['previewImage'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}

/// i am using class PlayingCard to avoid conflict with flutter's actual `Card` widget.
class PlayingCard {
  final int? id;
  final String name;       // "ace", "2"..."king"
  final String suit;       // "hearts", "spades", "diamonds", "clubs"
  final String imageUrl;   // store URL for simplicity
  final int? folderId;     // null = unassigned
  final DateTime createdAt;

  PlayingCard({
    this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    this.folderId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'suit': suit,
    'imageUrl': imageUrl,
    'folderId': folderId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PlayingCard.fromMap(Map<String, dynamic> m) => PlayingCard(
    id: m['id'] as int?,
    name: m['name'] as String,
    suit: m['suit'] as String,
    imageUrl: m['imageUrl'] as String,
    folderId: m['folderId'] as int?,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}
