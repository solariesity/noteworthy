class ExampleSentence {
  final String en;
  final String cn;

  const ExampleSentence({required this.en, required this.cn});

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      en: json['en'] as String,
      cn: json['cn'] as String,
    );
  }
}

class RootComponent {
  final String part;
  final String meaning;
  final String origin;
  final String? description;

  const RootComponent({
    required this.part,
    required this.meaning,
    required this.origin,
    this.description,
  });

  factory RootComponent.fromJson(Map<String, dynamic> json) {
    return RootComponent(
      part: json['part'] as String,
      meaning: json['meaning'] as String,
      origin: json['origin'] as String,
      description: json['description'] as String?,
    );
  }
}

class RootAnalysis {
  final List<RootComponent> components;
  final String? overallMeaning;

  const RootAnalysis({required this.components, this.overallMeaning});

  factory RootAnalysis.fromJson(Map<String, dynamic> json) {
    return RootAnalysis(
      overallMeaning: json['overallMeaning'] as String?,
      components: (json['components'] as List<dynamic>)
          .map((c) => RootComponent.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Collocation {
  final String phrase;
  final String meaning;

  const Collocation({required this.phrase, required this.meaning});

  factory Collocation.fromJson(Map<String, dynamic> json) {
    return Collocation(
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class WordEntry {
  final String word;
  final String pronunciation;
  final String definitionCn;
  final String definitionEn;
  final String partOfSpeech;
  final List<ExampleSentence> examples;
  final RootAnalysis? rootAnalysis;
  final List<Collocation> collocations;
  final String? difficulty;

  const WordEntry({
    required this.word,
    required this.pronunciation,
    required this.definitionCn,
    required this.definitionEn,
    required this.partOfSpeech,
    required this.examples,
    this.rootAnalysis,
    required this.collocations,
    this.difficulty,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String,
      definitionCn: json['definitionCn'] as String,
      definitionEn: json['definitionEn'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      difficulty: json['difficulty'] as String?,
      examples: (json['examples'] as List<dynamic>)
          .map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
          .toList(),
      rootAnalysis: json['rootAnalysis'] != null
          ? RootAnalysis.fromJson(json['rootAnalysis'] as Map<String, dynamic>)
          : null,
      collocations: (json['collocations'] as List<dynamic>)
          .map((c) => Collocation.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
