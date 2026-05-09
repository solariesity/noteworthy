import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/study_plan.dart';

class PlanStorage {
  Future<Directory> _plansDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/plans');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  File _indexFile(Directory dir) => File('${dir.path}/_index.json');
  File _planFile(Directory dir, String id) => File('${dir.path}/$id.json');
  File _stateFile(Directory dir) => File('${dir.path}/_state.json');

  Future<String?> loadActivePlanId() async {
    final dir = await _plansDir();
    final file = _stateFile(dir);
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;
      return map['activePlanId'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActivePlanId(String? id) async {
    final dir = await _plansDir();
    final file = _stateFile(dir);
    await file.writeAsString(json.encode({'activePlanId': id}));
  }

  Future<List<StudyPlanMeta>> loadIndex() async {
    final dir = await _plansDir();
    final file = _indexFile(dir);
    if (!await file.exists()) {
      return [];
    }
    try {
      final content = await file.readAsString();
      final list = json.decode(content) as List<dynamic>;
      return list
          .map((e) => StudyPlanMeta.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveIndex(List<StudyPlanMeta> plans) async {
    final dir = await _plansDir();
    final file = _indexFile(dir);
    final jsonStr = json.encode(plans.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonStr);
  }

  Future<StudyPlan?> loadPlan(String id) async {
    final dir = await _plansDir();
    final file = _planFile(dir, id);
    if (!await file.exists()) {
      return null;
    }
    try {
      final content = await file.readAsString();
      return StudyPlan.fromJson(json.decode(content) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlan(StudyPlan plan) async {
    final dir = await _plansDir();
    final file = _planFile(dir, plan.id);
    await file.writeAsString(json.encode(plan.toJson()));
  }

  Future<void> deletePlan(String id) async {
    final dir = await _plansDir();
    final file = _planFile(dir, id);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
