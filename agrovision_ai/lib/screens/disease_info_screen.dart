import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../core/crop_names.dart';
import '../data/disease_repository.dart';
import '../models/disease.dart';
import '../widgets/info_section.dart';
import '../widgets/medicine_tile.dart';
import '../widgets/smart_image.dart';

class DiseaseInfoScreen extends StatelessWidget {
  const DiseaseInfoScreen({required this.crop, super.key});

  static const routeName = '/disease-info';

  final String crop;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    final cropName = CropNames.localized(crop, language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$cropName ${strings.diseaseInfo}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<List<Disease>>(
        future: DiseaseRepository.instance.getDiseasesByCrop(crop),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final disease = snapshot.data![index];
              return _DiseaseExpansionTile(disease: disease);
            },
          );
        },
      ),
    );
  }
}

class _DiseaseExpansionTile extends StatelessWidget {
  const _DiseaseExpansionTile({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 145,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SmartImage(source: disease.image),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.70),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 14,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          disease.localizedName(language),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            disease.severity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: Text(
              strings.details,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [
              InfoSection(
                title: strings.symptoms,
                items: disease.localizedSymptoms(language),
                icon: Icons.warning_amber,
              ),
              InfoSection(
                title: strings.causes,
                items: disease.localizedCauses(language),
                icon: Icons.bug_report,
              ),
              InfoSection(
                title: strings.prevention,
                items: disease.localizedPrevention(language),
                icon: Icons.shield,
              ),
              InfoSection(
                title: strings.treatment,
                items: disease.localizedTreatment(language),
                icon: Icons.healing,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.medicines,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...disease.medicines.map(
                (medicine) =>
                    MedicineTile(medicine: medicine, language: language),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
