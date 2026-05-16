import '../core/app_language.dart';

class Disease {
  const Disease({
    required this.id,
    required this.crop,
    required this.label,
    required this.image,
    required this.severity,
    required this.name,
    required this.nameSd,
    required this.symptoms,
    required this.symptomsSd,
    required this.causes,
    required this.causesSd,
    required this.prevention,
    required this.preventionSd,
    required this.treatment,
    required this.treatmentSd,
    required this.medicines,
  });

  final String id;
  final String crop;
  final String label;
  final String image;
  final String severity;
  final String name;
  final String nameSd;
  final List<String> symptoms;
  final List<String> symptomsSd;
  final List<String> causes;
  final List<String> causesSd;
  final List<String> prevention;
  final List<String> preventionSd;
  final List<String> treatment;
  final List<String> treatmentSd;
  final List<Medicine> medicines;

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] as String,
      crop: json['crop'] as String,
      label: json['label'] as String,
      image: json['image'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Medium',
      name: json['name'] as String,
      nameSd: json['name_sd'] as String,
      symptoms: _stringList(json['symptoms']),
      symptomsSd: _stringList(json['symptoms_sd']),
      causes: _stringList(json['causes']),
      causesSd: _stringList(json['causes_sd']),
      prevention: _stringList(json['prevention']),
      preventionSd: _stringList(json['prevention_sd']),
      treatment: _stringList(json['treatment']),
      treatmentSd: _stringList(json['treatment_sd']),
      medicines: (json['medicines'] as List<dynamic>)
          .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String localizedName(AppLanguage language) =>
      language.isSindhi ? nameSd : name;

  List<String> localizedSymptoms(AppLanguage language) =>
      language.isSindhi ? symptomsSd : symptoms;

  List<String> localizedCauses(AppLanguage language) =>
      language.isSindhi ? causesSd : causes;

  List<String> localizedPrevention(AppLanguage language) =>
      language.isSindhi ? preventionSd : prevention;

  List<String> localizedTreatment(AppLanguage language) =>
      language.isSindhi ? treatmentSd : treatment;

  static List<String> _stringList(dynamic value) {
    return (value as List<dynamic>).map((item) => item.toString()).toList();
  }
}

class Medicine {
  const Medicine({
    required this.name,
    required this.nameSd,
    required this.dose,
    required this.image,
  });

  final String name;
  final String nameSd;
  final String dose;
  final String image;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String,
      nameSd: json['name_sd'] as String,
      dose: json['dose'] as String,
      image: json['image'] as String? ?? '',
    );
  }

  String localizedName(AppLanguage language) =>
      language.isSindhi ? nameSd : name;
}
