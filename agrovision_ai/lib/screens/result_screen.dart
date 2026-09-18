import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_fonts.dart';
import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../models/disease.dart';
import '../models/prediction_result.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/info_section.dart';
import '../widgets/language_switcher.dart';
import '../widgets/medicine_tile.dart';
import 'scan_screen.dart';

class ResultScreenArgs {
  const ResultScreenArgs({required this.image, required this.prediction});

  final File image;
  final PredictionResult prediction;
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({required this.args, super.key});

  static const routeName = '/result';

  final ResultScreenArgs args;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _savedFeedback;
  int _selectedTabIndex = 0;

  Future<void> _saveFeedback(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('prediction_feedback') ?? <String>[];
    final prediction = widget.args.prediction;
    final entry = [
      DateTime.now().toIso8601String(),
      prediction.label,
      prediction.confidence.toStringAsFixed(4),
      prediction.status.name,
      value,
    ].join('|');
    await prefs.setStringList('prediction_feedback', [...existing, entry]);
    if (!mounted) return;
    setState(() => _savedFeedback = value);
    final strings = AppStrings(AppScope.of(context).language);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.thanksFeedback)));
  }

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    final prediction = widget.args.prediction;
    final disease = prediction.disease;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.result,
          style: TextStyle(
            fontFamily: AppFonts.heading(language),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Captured Image Banner
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softCardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  widget.args.image,
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          strings.aiConfirmed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hero Diagnosis Card with Circular Confidence Gauge
          _HeroDiagnosisCard(
            prediction: prediction,
            disease: disease,
            language: language,
            strings: strings,
          ),
          const SizedBox(height: 16),

          // If no disease matched
          if (disease == null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppDecorations.card(),
              child: Text(
                strings.noMatch,
                style: TextStyle(
                  fontFamily: AppFonts.body(language),
                  fontSize: 14,
                ),
              ),
            )
          else ...[
            // Segmented Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SegmentPill(
                    label: strings.tabOverview,
                    icon: Icons.dashboard_outlined,
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _SegmentPill(
                    label: strings.tabSymptoms,
                    icon: Icons.warning_amber_rounded,
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _SegmentPill(
                    label: strings.tabTreatment,
                    icon: Icons.healing_rounded,
                    isSelected: _selectedTabIndex == 2,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                  const SizedBox(width: 8),
                  _SegmentPill(
                    label: strings.tabMedicines,
                    icon: Icons.medication_rounded,
                    isSelected: _selectedTabIndex == 3,
                    onTap: () => setState(() => _selectedTabIndex = 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Content
            if (_selectedTabIndex == 0) ...[
              // Overview Tab
              if (disease.recommendationSummary.isNotEmpty)
                _ActionSummaryCard(disease: disease),
              _QualityCard(prediction: prediction),
              if (!prediction.shouldShowTreatment)
                _UncertainTreatmentCard(strings: strings),
              _SafetyCard(strings: strings),
            ] else if (_selectedTabIndex == 1) ...[
              // Symptoms & Causes Tab
              InfoSection(
                title: strings.symptoms,
                items: disease.localizedSymptoms(language),
                icon: Icons.warning_amber_rounded,
              ),
              InfoSection(
                title: strings.causes,
                items: disease.localizedCauses(language),
                icon: Icons.bug_report_rounded,
              ),
              if (disease.falsePositiveTriggers.isNotEmpty)
                InfoSection(
                  title: strings.falsePositiveRisks,
                  items: disease.localizedFalsePositiveTriggers(language),
                  icon: Icons.search_off_rounded,
                ),
            ] else if (_selectedTabIndex == 2) ...[
              // Treatment & Prevention Tab
              if (prediction.shouldShowTreatment) ...[
                InfoSection(
                  title: strings.treatment,
                  items: disease.localizedTreatment(language),
                  icon: Icons.healing_rounded,
                ),
                InfoSection(
                  title: strings.prevention,
                  items: disease.localizedPrevention(language),
                  icon: Icons.shield_rounded,
                ),
                if (disease.progressionStages.isNotEmpty)
                  InfoSection(
                    title: strings.progression,
                    items: disease.localizedProgressionStages(language),
                    icon: Icons.timeline_rounded,
                  ),
              ] else ...[
                _UncertainTreatmentCard(strings: strings),
              ],
            ] else if (_selectedTabIndex == 3) ...[
              // Medicines Tab
              if (prediction.shouldShowTreatment) ...[
                Text(
                  strings.medicines,
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 8),
                if (disease.medicines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card(),
                    child: Text(
                      strings.language.isSindhi
                          ? 'هن بيماري لاءِ خاص دوا جي ضرورت ناهي.'
                          : 'No specific chemical medicine required.',
                      style: TextStyle(
                        fontFamily: AppFonts.body(language),
                        color: AppColors.textMedium,
                      ),
                    ),
                  )
                else
                  ...disease.medicines.map(
                    (medicine) => MedicineTile(
                      medicine: medicine,
                      language: language,
                    ),
                  ),
                _SafetyCard(strings: strings),
              ] else ...[
                _UncertainTreatmentCard(strings: strings),
              ],
            ],
          ],

          const SizedBox(height: 16),

          // Feedback Section
          _FeedbackCard(
            savedFeedback: _savedFeedback,
            onSelected: _saveFeedback,
          ),
          const SizedBox(height: 18),

          // Scan Again Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, ScanScreen.routeName),
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text(
              strings.retry,
              style: TextStyle(
                fontFamily: AppFonts.heading(language),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x28159957),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: isSelected
                    ? AppFonts.heading(language)
                    : AppFonts.body(language),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDiagnosisCard extends StatelessWidget {
  const _HeroDiagnosisCard({
    required this.prediction,
    required this.disease,
    required this.language,
    required this.strings,
  });

  final PredictionResult prediction;
  final Disease? disease;
  final AppLanguage language;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final status = prediction.status;
    final statusColor = switch (status) {
      PredictionStatus.reliable => AppColors.statusReliable,
      PredictionStatus.possible => AppColors.statusPossible,
      PredictionStatus.uncertain => AppColors.statusUncertain,
    };

    final title = disease?.localizedName(language) ?? prediction.label;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card(
        borderRadius: 20,
        borderColor: AppColors.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular Gauge
              ConfidenceGauge(
                confidence: prediction.confidence,
                status: status,
                size: 96,
              ),
              const SizedBox(width: 16),

              // Title & Status Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.heading(language),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.forest,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            switch (status) {
                              PredictionStatus.reliable => Icons.verified_rounded,
                              PredictionStatus.possible => Icons.help_outline_rounded,
                              PredictionStatus.uncertain => Icons.report_problem_rounded,
                            },
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _statusLabel(strings, status),
                            style: TextStyle(
                              fontFamily: AppFonts.heading(language),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (disease != null)
                      Text(
                        strings.localizedRisk(disease!.severity),
                        style: TextStyle(
                          fontFamily: AppFonts.body(language),
                          color: AppColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Advice note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusAdvice(strings, status),
              style: TextStyle(
                fontFamily: AppFonts.body(language),
                color: AppColors.textMedium,
                height: 1.4,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppStrings strings, PredictionStatus status) {
    return switch (status) {
      PredictionStatus.reliable => strings.reliable,
      PredictionStatus.possible => strings.possible,
      PredictionStatus.uncertain => strings.uncertain,
    };
  }

  String _statusAdvice(AppStrings strings, PredictionStatus status) {
    return switch (status) {
      PredictionStatus.reliable => strings.reliableAdvice,
      PredictionStatus.possible => strings.possibleAdvice,
      PredictionStatus.uncertain => strings.uncertainAdvice,
    };
  }
}

class _ActionSummaryCard extends StatelessWidget {
  const _ActionSummaryCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6ECC2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.quickAdvice,
                style: TextStyle(
                  fontFamily: AppFonts.heading(language),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            disease.localizedRecommendationSummary(language),
            style: TextStyle(
              fontFamily: AppFonts.body(language),
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: AppColors.forest,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${strings.actionUrgency}: ${strings.localizedUrgency(disease.actionUrgency)}',
                  style: TextStyle(
                    fontFamily: AppFonts.body(language),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${strings.ipmScore}: ${disease.ipmScore}/10',
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  const _QualityCard({required this.prediction});

  final PredictionResult prediction;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    final issues = prediction.quality.issues;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.mintLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image_search_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.qualityCheck,
                style: TextStyle(
                  fontFamily: AppFonts.heading(language),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (issues.isEmpty)
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  strings.qualityGood,
                  style: TextStyle(
                    fontFamily: AppFonts.body(language),
                    color: AppColors.textDark,
                    fontSize: 13,
                  ),
                ),
              ],
            )
          else
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.statusUncertain,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _issueText(strings, issue),
                        style: TextStyle(
                          fontFamily: AppFonts.body(language),
                          color: AppColors.statusUncertain,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _issueText(AppStrings strings, ImageQualityIssue issue) {
    return switch (issue) {
      ImageQualityIssue.lowResolution => strings.lowResolutionWarning,
      ImageQualityIssue.tooDark => strings.darkImageWarning,
      ImageQualityIssue.tooBright => strings.brightImageWarning,
      ImageQualityIssue.blurry => strings.blurryImageWarning,
    };
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded, color: Color(0xFFD97706), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.safetyNote,
              style: TextStyle(
                fontFamily: AppFonts.body(language),
                height: 1.4,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UncertainTreatmentCard extends StatelessWidget {
  const _UncertainTreatmentCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD2C2)),
      ),
      child: Text(
        strings.uncertainAdvice,
        style: TextStyle(
          fontFamily: AppFonts.body(language),
          height: 1.4,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF7C2D12),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.savedFeedback, required this.onSelected});

  final String? savedFeedback;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.feedback,
            style: TextStyle(
              fontFamily: AppFonts.heading(language),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeedbackButton(
                value: 'correct',
                label: strings.correct,
                selected: savedFeedback == 'correct',
                icon: Icons.thumb_up_alt_rounded,
                onSelected: onSelected,
              ),
              _FeedbackButton(
                value: 'wrong',
                label: strings.wrong,
                selected: savedFeedback == 'wrong',
                icon: Icons.thumb_down_alt_rounded,
                onSelected: onSelected,
              ),
              _FeedbackButton(
                value: 'not_sure',
                label: strings.notSure,
                selected: savedFeedback == 'not_sure',
                icon: Icons.help_outline_rounded,
                onSelected: onSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.value,
    required this.label,
    required this.selected,
    required this.icon,
    required this.onSelected,
  });

  final String value;
  final String label;
  final bool selected;
  final IconData icon;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      selectedColor: AppColors.mint,
      checkmarkColor: AppColors.primaryDark,
      avatar: Icon(
        icon,
        size: 15,
        color: selected ? AppColors.primaryDark : AppColors.textMedium,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: selected ? AppColors.forest : AppColors.textDark,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}
