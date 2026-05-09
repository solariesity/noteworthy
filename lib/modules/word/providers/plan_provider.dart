import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/study_plan.dart';
import '../models/word_entry.dart';
import '../services/plan_storage.dart';
import 'word_provider.dart';

class PlanProvider extends ChangeNotifier {
  final PlanStorage _storage = PlanStorage();
  final Uuid _uuid = const Uuid();

  List<StudyPlanMeta> _plans = [];
  StudyPlan? _currentPlan;
  bool _loaded = false;
  String? _activePlanId;

  List<StudyPlanMeta> get plans => _plans;
  StudyPlan? get currentPlan => _currentPlan;
  bool get isLoaded => _loaded;
  String? get activePlanId => _activePlanId;

  Future<void> initialize() async {
    if (_loaded) return;
    _plans = await _storage.loadIndex();

    if (_plans.isEmpty) {
      await _createDemoPlan();
    }

    _activePlanId = await _storage.loadActivePlanId();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _createDemoPlan() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final words = jsonList
          .map((j) => WordEntry.fromJson(j as Map<String, dynamic>))
          .toList();

      final plan = StudyPlan(
        id: _uuid.v4(),
        name: 'demo',
        description: '',
        words: words,
        createdAt: DateTime.now(),
      );
      _plans.add(plan.meta);
      await _storage.savePlan(plan);
      await _storage.saveIndex(_plans);
    } catch (_) {
      // words.json not available — demo plan will be empty or skip
    }
  }

  void setActivePlan(String id) {
    _activePlanId = id;
    _storage.saveActivePlanId(id);
    notifyListeners();
  }

  Future<void> createPlan(String name, String description) async {
    final id = _uuid.v4();
    final plan = StudyPlan(
      id: id,
      name: name,
      description: description,
      words: [],
      createdAt: DateTime.now(),
    );
    _plans.add(plan.meta);
    await _storage.savePlan(plan);
    await _storage.saveIndex(_plans);
    notifyListeners();
  }

  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    if (_currentPlan?.id == id) {
      _currentPlan = null;
    }
    if (_activePlanId == id) {
      _activePlanId = null;
      _storage.saveActivePlanId(null);
    }
    await _storage.deletePlan(id);
    await _storage.saveIndex(_plans);
    notifyListeners();
  }

  Future<void> updatePlanMeta(String id, String name, String description) async {
    final plan = await _storage.loadPlan(id);
    if (plan == null) return;

    final updated = StudyPlan(
      id: plan.id,
      name: name,
      description: description,
      words: plan.words,
      createdAt: plan.createdAt,
    );
    await _storage.savePlan(updated);

    final index = _plans.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _plans[index] = updated.meta;
      await _storage.saveIndex(_plans);
    }

    if (_currentPlan?.id == id) {
      _currentPlan = updated;
    }
    notifyListeners();
  }

  Future<int> importFromJson(String planId, String jsonString) async {
    final plan = await _storage.loadPlan(planId);
    if (plan == null) return 0;

    final existingWords = plan.words.map((w) => w.word).toSet();
    final List<dynamic> jsonList = json.decode(jsonString);
    final newWords = jsonList
        .map((j) => WordEntry.fromJson(j as Map<String, dynamic>))
        .where((w) => !existingWords.contains(w.word))
        .toList();

    if (newWords.isEmpty) return 0;

    final updated = StudyPlan(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      words: [...plan.words, ...newWords],
      createdAt: plan.createdAt,
    );
    await _storage.savePlan(updated);

    final index = _plans.indexWhere((p) => p.id == planId);
    if (index >= 0) {
      _plans[index] = updated.meta;
      await _storage.saveIndex(_plans);
    }

    if (_currentPlan?.id == planId) {
      _currentPlan = updated;
    }
    notifyListeners();
    return newWords.length;
  }

  Future<int> importFromCsv(String planId, String csvString) async {
    final plan = await _storage.loadPlan(planId);
    if (plan == null) return 0;

    final existingWords = plan.words.map((w) => w.word).toSet();
    final lines = csvString.trim().split('\n');
    final newWords = <WordEntry>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length < 3) continue;

      final word = parts[0].trim();
      if (existingWords.contains(word)) continue;
      existingWords.add(word);

      newWords.add(WordEntry(
        word: word,
        pronunciation: parts.length > 4 ? parts[4].trim() : '',
        definitionCn: parts[1].trim(),
        definitionEn: parts.length > 2 ? parts[2].trim() : '',
        partOfSpeech: parts.length > 3 ? parts[3].trim() : '',
        examples: [],
        rootAnalysis: null,
        collocations: [],
      ));
    }

    if (newWords.isEmpty) return 0;

    final updated = StudyPlan(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      words: [...plan.words, ...newWords],
      createdAt: plan.createdAt,
    );
    await _storage.savePlan(updated);

    final index = _plans.indexWhere((p) => p.id == planId);
    if (index >= 0) {
      _plans[index] = updated.meta;
      await _storage.saveIndex(_plans);
    }

    if (_currentPlan?.id == planId) {
      _currentPlan = updated;
    }
    notifyListeners();
    return newWords.length;
  }

  Future<void> deleteWord(String planId, int wordIndex) async {
    final plan = await _storage.loadPlan(planId);
    if (plan == null || wordIndex < 0 || wordIndex >= plan.words.length) return;

    final updatedWords = [...plan.words];
    updatedWords.removeAt(wordIndex);

    final updated = StudyPlan(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      words: updatedWords,
      createdAt: plan.createdAt,
    );
    await _storage.savePlan(updated);

    final index = _plans.indexWhere((p) => p.id == planId);
    if (index >= 0) {
      _plans[index] = updated.meta;
      await _storage.saveIndex(_plans);
    }

    if (_currentPlan?.id == planId) {
      _currentPlan = updated;
    }
    notifyListeners();
  }

  Future<StudyPlan?> loadPlan(String id) async {
    final plan = await _storage.loadPlan(id);
    if (plan != null) {
      _currentPlan = plan;
      notifyListeners();
    }
    return plan;
  }

  void startLearning(StudyPlan plan, WordProvider wordProvider) {
    _currentPlan = plan;
    _activePlanId = plan.id;
    _storage.saveActivePlanId(plan.id);
    wordProvider.loadPlanWords(plan.words);
    notifyListeners();
  }
}
