import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../models/prediction_result.dart';
import '../widgets/info_section.dart';
import '../widgets/language_switcher.dart';
import '../widgets/medicine_tile.dart';
import '../widgets/smart_image.dart';
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
    final confidence = (prediction.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.result,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              widget.args.image,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          _PredictionHeader(
            prediction: prediction,
            title: disease?.localizedName(language) ?? prediction.label,
            confidence: confidence,
          ),
          const SizedBox(height: 12),
          _QualityCard(prediction: prediction),
          const SizedBox(height: 12),
          if (disease == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(strings.noMatch),
              ),
            )
          else if (prediction.shouldShowTreatment) ...[
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
              title: strings.treatment,
              items: disease.localizedTreatment(language),
              icon: Icons.healing,
            ),
            Text(
              strings.medicines,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...disease.medicines.map(
              (medicine) =>
                  MedicineTile(medicine: medicine, language: language),
            ),
            _SafetyCard(strings: strings),
          ] else ...[
            InfoSection(
              title: strings.symptoms,
              items: disease.localizedSymptoms(language),
              icon: Icons.warning_amber,
            ),
            _UncertainTreatmentCard(strings: strings),
          ],
          const SizedBox(height: 12),
          _FeedbackCard(
            savedFeedback: _savedFeedback,
            onSelected: _saveFeedback,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, ScanScreen.routeName),
            icon: const Icon(Icons.camera_alt),
            label: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}

class _PredictionHeader extends StatelessWidget {
  const _PredictionHeader({
    required this.prediction,
    required this.title,
    required this.confidence,
  });

  final PredictionResult prediction;
  final String title;
  final String confidence;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    final status = prediction.status;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (prediction.disease != null) ...[
              const SizedBox(height: 12),
              SmartImage(
                source: prediction.disease!.image,
                height: 120,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(_statusIcon(status), color: _statusColor(status)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${strings.confidence}: $confidence% - ${_statusLabel(strings, status)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _statusAdvice(strings, status),
              style: const TextStyle(color: Color(0xFF60756B), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(PredictionStatus status) {
    return switch (status) {
      PredictionStatus.reliable => const Color(0xFF159957),
      PredictionStatus.possible => const Color(0xFFD48A00),
      PredictionStatus.uncertain => const Color(0xFFC2410C),
    };
  }

  IconData _statusIcon(PredictionStatus status) {
    return switch (status) {
      PredictionStatus.reliable => Icons.verified,
      PredictionStatus.possible => Icons.help,
      PredictionStatus.uncertain => Icons.report_problem,
    };
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

class _QualityCard extends StatelessWidget {
  const _QualityCard({required this.prediction});

  final PredictionResult prediction;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    final issues = prediction.quality.issues;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image_search, color: Color(0xFF159957)),
                const SizedBox(width: 8),
                Text(
                  strings.qualityCheck,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (issues.isEmpty)
              Text(strings.qualityGood)
            else
              ...issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: Color(0xFFC2410C),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_issueText(strings, issue))),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
    return Card(
      color: const Color(0xFFFFF8E7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.health_and_safety, color: Color(0xFFD48A00)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.safetyNote,
                style: const TextStyle(
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UncertainTreatmentCard extends StatelessWidget {
  const _UncertainTreatmentCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF1EB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.uncertainAdvice,
          style: const TextStyle(height: 1.35, fontWeight: FontWeight.w800),
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
    final strings = AppStrings(AppScope.of(context).language);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.feedback,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
                  onSelected: onSelected,
                ),
                _FeedbackButton(
                  value: 'wrong',
                  label: strings.wrong,
                  selected: savedFeedback == 'wrong',
                  onSelected: onSelected,
                ),
                _FeedbackButton(
                  value: 'not_sure',
                  label: strings.notSure,
                  selected: savedFeedback == 'not_sure',
                  onSelected: onSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.value,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String value;
  final String label;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(value),
    );
  }
}
