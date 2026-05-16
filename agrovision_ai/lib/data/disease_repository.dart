import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/disease.dart';

class DiseaseRepository {
  DiseaseRepository._();

  static final DiseaseRepository instance = DiseaseRepository._();

  List<Disease>? _cache;

  Future<List<Disease>> getDiseases() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/diseases.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (decoded['diseases'] as List<dynamic>)
        .map((item) => Disease.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<String>> getCrops() async {
    final diseases = await getDiseases();
    return diseases.map((disease) => disease.crop).toSet().toList()..sort();
  }

  Future<List<Disease>> getDiseasesByCrop(String crop) async {
    final diseases = await getDiseases();
    return diseases
        .where((disease) => disease.crop.toLowerCase() == crop.toLowerCase())
        .toList();
  }

  Future<Disease?> findByLabel(String label) async {
    final normalized = _normalize(label);
    final diseases = await getDiseases();
    for (final disease in diseases) {
      if (_normalize(disease.label) == normalized ||
          _normalize(disease.name) == normalized) {
        return disease;
      }
    }
    return null;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
