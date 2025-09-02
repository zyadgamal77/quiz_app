
class Category {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final String ownerId;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    required this.ownerId,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        createdAt: map['createdAt']?.toDate(),
        ownerId: map['ownerId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
      'ownerId': ownerId,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
  })
  {
  return Category(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt,
    ownerId: ownerId ?? this.ownerId,
  );
  }
}
