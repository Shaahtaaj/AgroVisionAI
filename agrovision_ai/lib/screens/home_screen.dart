import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../core/crop_names.dart';
import '../data/disease_repository.dart';
import '../models/disease.dart';
import '../widgets/language_switcher.dart';
import '../widgets/smart_image.dart';
import 'about_screen.dart';
import 'disease_info_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: const [
          _AboutButton(),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0B7A3B),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, ScanScreen.routeName),
        icon: const Icon(Icons.camera_alt),
        label: Text(strings.scanLeaf),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder<List<Disease>>(
        future: DiseaseRepository.instance.getDiseases(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final diseases = snapshot.data!;
          final crops = diseases.map((disease) => disease.crop).toSet().toList()
            ..sort();
          final mangoDiseases = diseases
              .where((disease) => disease.crop.toLowerCase() == 'mango')
              .take(4)
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              _ClassifierHero(strings: strings),
              const SizedBox(height: 18),
              Text(
                strings.crops,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...crops.map((crop) => _CropCard(crop: crop, diseases: diseases)),
              const SizedBox(height: 12),
              Text(
                strings.classifierLibrary,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 188,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mangoDiseases.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _FeaturedDiseaseCard(disease: mangoDiseases[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  const _AboutButton();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    return IconButton(
      tooltip: strings.about,
      onPressed: () => Navigator.pushNamed(context, AboutScreen.routeName),
      icon: const Icon(Icons.info_outline),
    );
  }
}

class _ClassifierHero extends StatelessWidget {
  const _ClassifierHero({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF113B2E), Color(0xFF159957)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26159957),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.tagLine,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.classifierBody,
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0B7A3B),
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, ScanScreen.routeName),
                  icon: const Icon(Icons.center_focus_strong),
                  label: Text(strings.scanLeaf),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/images/agrovision_logo.png', width: 86),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({required this.crop, required this.diseases});

  final String crop;
  final List<Disease> diseases;

  @override
  Widget build(BuildContext context) {
    final isMango = crop.toLowerCase() == 'mango';
    final count = diseases.where((disease) => disease.crop == crop).length;
    final language = AppScope.of(context).language;
    final cropName = CropNames.localized(crop, language);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamed(
          context,
          DiseaseInfoScreen.routeName,
          arguments: crop,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: isMango
                  ? const [Color(0xFFEAF8D8), Color(0xFFFFFFFF)]
                  : const [Color(0xFFE8F4EF), Color(0xFFFFFFFF)],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFF159957),
                child: Icon(
                  isMango ? Icons.eco : Icons.grass,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count disease records',
                      style: const TextStyle(color: Color(0xFF60756B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedDiseaseCard extends StatelessWidget {
  const _FeaturedDiseaseCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            DiseaseInfoScreen.routeName,
            arguments: disease.crop,
          ),
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
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                start: 12,
                end: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.localizedName(language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disease.severity,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
