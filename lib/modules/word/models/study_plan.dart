import 'word_entry.dart';

class StudyPlanMeta {
  final String id;
  final String name;
  final String description;
  final int wordCount;
  final DateTime createdAt;

  const StudyPlanMeta({
    required this.id,
    required this.name,
    required this.description,
    required this.wordCount,
    required this.createdAt,
  });

  factory StudyPlanMeta.fromJson(Map<String, dynamic> json) {
    return StudyPlanMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      wordCount: json['wordCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'wordCount': wordCount,
    'createdAt': createdAt.toIso8601String(),
  };

  StudyPlanMeta copyWith({
    String? name,
    String? description,
    int? wordCount,
  }) {
    return StudyPlanMeta(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt,
    );
  }
}

class StudyPlan {
  final String id;
  final String name;
  final String description;
  final List<WordEntry> words;
  final DateTime createdAt;

  const StudyPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.words,
    required this.createdAt,
  });

  StudyPlanMeta get meta => StudyPlanMeta(
    id: id,
    name: name,
    description: description,
    wordCount: words.length,
    createdAt: createdAt,
  );

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      words: (json['words'] as List<dynamic>)
          .map((w) => WordEntry.fromJson(w as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'words': words.map((w) => w.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}
