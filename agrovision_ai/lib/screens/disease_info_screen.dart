import 'package:flutter/material.dart';

import '../core/agri_terms.dart';
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
      body: FutureBuilder<List<DiseaseCatalogEntry>>(
        future: DiseaseRepository.instance.getDiseaseCatalogByCrop(crop),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final entry = snapshot.data![index];
              return _DiseaseExpansionTile(
                disease: entry.disease,
                isAiDetectable: entry.isAiDetectable,
              );
            },
          );
        },
      ),
    );
  }
}

class _DiseaseExpansionTile extends StatelessWidget {
  const _DiseaseExpansionTile({
    required this.disease,
    required this.isAiDetectable,
  });

  final Disease disease;
  final bool isAiDetectable;

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
                  top: 12,
                  end: 12,
                  child: _DetectabilityBadge(isAiDetectable: isAiDetectable),
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
                            strings.localizedRisk(disease.severity),
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
              if (disease.localizedOverview(language).isNotEmpty)
                InfoSection(
                  title: strings.details,
                  items: [disease.localizedOverview(language)],
                  icon: Icons.info,
                ),
              _RelatedTermsCard(disease: disease),
              _QuickAdviceCard(disease: disease),
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
              _StageManagementCard(disease: disease),
              InfoSection(
                title: strings.fieldConditions,
                items: disease.favorableConditions.asList(strings),
                icon: Icons.cloud,
              ),
              InfoSection(
                title: strings.progression,
                items: disease.localizedProgressionStages(language),
                icon: Icons.timeline,
              ),
              InfoSection(
                title: strings.coInfections,
                items: disease.localizedCoInfections(language),
                icon: Icons.hub,
              ),
              InfoSection(
                title: strings.falsePositiveRisks,
                items: disease.localizedFalsePositiveTriggers(language),
                icon: Icons.visibility_off,
              ),
              InfoSection(
                title: strings.focusRegions,
                items: disease.localizedMlFocusRegions(language),
                icon: Icons.center_focus_strong,
              ),
              if (disease.resistanceNotes.isNotEmpty)
                InfoSection(
                  title: strings.resistanceNotes,
                  items: [disease.localizedResistanceNotes(language)],
                  icon: Icons.science,
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

class _DetectabilityBadge extends StatelessWidget {
  const _DetectabilityBadge({required this.isAiDetectable});

  final bool isAiDetectable;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    final background = isAiDetectable
        ? const Color(0xFF0B7A3B)
        : const Color(0xFF8A4B08);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white54),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAiDetectable ? Icons.auto_awesome : Icons.menu_book,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              isAiDetectable ? strings.aiDetectable : strings.informationOnly,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedTermsCard extends StatelessWidget {
  const _RelatedTermsCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    final text = [
      disease.localizedName(language),
      disease.localizedOverview(language),
      ...disease.localizedSymptoms(language),
      ...disease.localizedCauses(language),
      ...disease.localizedTreatment(language),
    ].join(' ');
    final terms = AgriTerms.forText(text, language);
    if (terms.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFF159957)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.relatedAgriWords,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...terms.map(
              (term) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FAF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCEADE)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term.sindhi,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          term.definitionSd,
                          style: const TextStyle(
                            color: Color(0xFF60756B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAdviceCard extends StatelessWidget {
  const _QuickAdviceCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFEAF8D8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Color(0xFF0B7A3B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.quickAdvice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              disease.localizedRecommendationSummary(
                AppScope.of(context).language,
              ),
              style: const TextStyle(
                color: Color(0xFF263D33),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.priority_high,
                  label:
                      '${strings.actionUrgency}: ${strings.localizedUrgency(disease.actionUrgency)}',
                ),
                _MetricChip(
                  icon: Icons.eco,
                  label: '${strings.ipmScore}: ${disease.ipmScore}/10',
                ),
                _MetricChip(
                  icon: Icons.trending_up,
                  label:
                      '${strings.recurrenceRisk}: ${strings.localizedRisk(disease.recurrenceRisk)}',
                ),
                _MetricChip(
                  icon: Icons.payments,
                  label:
                      '${strings.economics}: ${strings.localizedRisk(disease.treatmentCostEstimate)}',
                ),
                if (disease.preHarvestIntervalDays > 0)
                  _MetricChip(
                    icon: Icons.event_available,
                    label:
                        '${strings.preHarvestInterval}: ${disease.preHarvestIntervalDays} ${strings.days}',
                  ),
              ],
            ),
            if (disease.economicThresholdAction.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                disease.localizedEconomicThresholdAction(
                  AppScope.of(context).language,
                ),
                style: const TextStyle(color: Color(0xFF60756B), height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StageManagementCard extends StatelessWidget {
  const _StageManagementCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.stageManagement,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _StageBlock(
              title: strings.earlyStage,
              color: const Color(0xFF159957),
              items: disease.localizedStageItems(
                disease.stageBasedManagement.early,
                AppScope.of(context).language,
              ),
            ),
            _StageBlock(
              title: strings.moderateStage,
              color: const Color(0xFFD48A00),
              items: disease.localizedStageItems(
                disease.stageBasedManagement.moderate,
                AppScope.of(context).language,
              ),
            ),
            _StageBlock(
              title: strings.severeStage,
              color: const Color(0xFFC2410C),
              items: disease.localizedStageItems(
                disease.stageBasedManagement.severe,
                AppScope.of(context).language,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageBlock extends StatelessWidget {
  const _StageBlock({
    required this.title,
    required this.color,
    required this.items,
  });

  final String title;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item, style: const TextStyle(height: 1.35)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17, color: const Color(0xFF0B7A3B)),
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDCEADE)),
    );
  }
}
