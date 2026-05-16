import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../models/disease.dart';
import 'smart_image.dart';

class MedicineTile extends StatelessWidget {
  const MedicineTile({
    required this.medicine,
    required this.language,
    super.key,
  });

  final Medicine medicine;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: SizedBox(
          width: 54,
          height: 54,
          child: SmartImage(
            source: medicine.image,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(
          medicine.localizedName(language),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(medicine.dose),
      ),
    );
  }
}
