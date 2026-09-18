import 'package:flutter/material.dart';

import '../core/app_fonts.dart';
import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../core/crop_names.dart';
import '../data/disease_repository.dart';
import '../models/disease.dart';
import '../widgets/language_switcher.dart';
import '../widgets/smart_image.dart';
import 'about_screen.dart';
import 'agri_terms_screen.dart';
import 'disease_info_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String? _selectedCrop;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/agrovision_logo.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                strings.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.heading(language),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.forest,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          _AboutButton(),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () => Navigator.pushNamed(context, ScanScreen.routeName),
        icon: const Icon(Icons.center_focus_strong_rounded, size: 22),
        label: Text(
          strings.scanLeaf,
          style: TextStyle(
            fontFamily: AppFonts.heading(language),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder<List<Disease>>(
        future: DiseaseRepository.instance.getDiseases(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final diseases = snapshot.data!;
          final crops = diseases.map((d) => d.crop).toSet().toList()..sort();

          final filteredDiseases = _filterDiseases(diseases, language);
          final displayedCrops = _selectedCrop == null
              ? crops
              : crops.where((c) => c == _selectedCrop).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
            children: [
              // Farmer Greeting Card
              _GreetingHeader(strings: strings, language: language),
              const SizedBox(height: 14),

              // Weather & Field Advisory Alert
              _AdvisoryBanner(strings: strings, language: language),
              const SizedBox(height: 16),

              // Bento Quick Action Hero Card
              _BentoScannerHero(strings: strings, language: language),
              const SizedBox(height: 12),

              // Secondary Bento Row
              Row(
                children: [
                  Expanded(
                    child: _BentoGlossaryCard(strings: strings, language: language),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BentoStatsCard(
                      diseaseCount: diseases.length,
                      language: language,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Field
              TextField(
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(fontFamily: AppFonts.body(language), fontSize: 14),
                decoration: InputDecoration(
                  hintText: strings.searchKnowledge,
                  hintStyle: TextStyle(
                    fontFamily: AppFonts.body(language),
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crop Filter Chips Slider
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterPill(
                      label: strings.allCrops,
                      isSelected: _selectedCrop == null,
                      onTap: () => setState(() => _selectedCrop = null),
                      language: language,
                    ),
                    const SizedBox(width: 8),
                    ...crops.map((crop) {
                      final localized = CropNames.localized(crop, language);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterPill(
                          label: localized,
                          isSelected: _selectedCrop == crop,
                          onTap: () => setState(() => _selectedCrop = crop),
                          language: language,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Crops Heading
              Text(
                strings.crops,
                style: TextStyle(
                  fontFamily: AppFonts.heading(language),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 10),

              // Crop Catalog Cards
              ...displayedCrops.map(
                (crop) => _ModernCropCard(
                  crop: crop,
                  diseases: diseases,
                  language: language,
                ),
              ),
              const SizedBox(height: 16),

              // Featured Diseases Carousel Section
              Text(
                _query.trim().isEmpty
                    ? strings.classifierLibrary
                    : strings.knowledgeHub,
                style: TextStyle(
                  fontFamily: AppFonts.heading(language),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 196,
                child: filteredDiseases.isEmpty
                    ? Container(
                        decoration: AppDecorations.card(),
                        alignment: Alignment.center,
                        child: Text(
                          strings.noMatch,
                          style: TextStyle(fontFamily: AppFonts.body(language)),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredDiseases.take(6).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return _ModernFeaturedDiseaseCard(
                            disease: filteredDiseases[index],
                            language: language,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Disease> _filterDiseases(List<Disease> diseases, AppLanguage language) {
    var list = diseases;
    if (_selectedCrop != null) {
      list = list.where((d) => d.crop == _selectedCrop).toList();
    }
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((disease) {
      final haystack = [
        disease.name,
        disease.nameSd,
        disease.crop,
        CropNames.localized(disease.crop, language),
        disease.label,
        disease.severity,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.strings, required this.language});

  final AppStrings strings;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.farmerGreeting,
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.forest,
                  ),
                ),
                Text(
                  strings.tagLine,
                  style: TextStyle(
                    fontFamily: AppFonts.body(language),
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryBanner extends StatelessWidget {
  const _AdvisoryBanner({required this.strings, required this.language});

  final AppStrings strings;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_sync_rounded,
              color: Color(0xFFD97706),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.fieldAdvisoryTitle,
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  strings.fieldAdvisorySubtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.body(language),
                    fontSize: 12,
                    height: 1.35,
                    color: const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoScannerHero extends StatelessWidget {
  const _BentoScannerHero({required this.strings, required this.language});

  final AppStrings strings;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.primary],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30159957),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.offline_bolt_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        strings.offlineLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.quickScanCardTitle,
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.quickScanCardSubtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.body(language),
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, ScanScreen.routeName),
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
                  label: Text(
                    strings.scanLeaf,
                    style: TextStyle(
                      fontFamily: AppFonts.heading(language),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Hero(
            tag: 'app-logo',
            child: Image.asset(
              'assets/images/agrovision_logo.png',
              width: 82,
              height: 82,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoGlossaryCard extends StatelessWidget {
  const _BentoGlossaryCard({required this.strings, required this.language});

  final AppStrings strings;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AgriTermsScreen.routeName),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(borderRadius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.mintLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.agriWords,
              style: TextStyle(
                fontFamily: AppFonts.heading(language),
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.agriWordsSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.body(language),
                color: AppColors.textMedium,
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoStatsCard extends StatelessWidget {
  const _BentoStatsCard({
    required this.diseaseCount,
    required this.language,
    required this.strings,
  });

  final int diseaseCount;
  final AppLanguage language;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sage,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$diseaseCount Diseases',
            style: TextStyle(
              fontFamily: AppFonts.heading(language),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '5 Crops • 8 AI Models',
            style: TextStyle(
              fontFamily: AppFonts.body(language),
              color: AppColors.textMedium,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.language,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x24159957),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: isSelected
                ? AppFonts.heading(language)
                : AppFonts.body(language),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _ModernCropCard extends StatelessWidget {
  const _ModernCropCard({
    required this.crop,
    required this.diseases,
    required this.language,
  });

  final String crop;
  final List<Disease> diseases;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isMango = crop.toLowerCase() == 'mango';
    final count = diseases.where((d) => d.crop == crop).length;
    final strings = AppStrings(language);
    final cropName = CropNames.localized(crop, language);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card(borderRadius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            DiseaseInfoScreen.routeName,
            arguments: crop,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isMango ? AppColors.mintLight : const Color(0xFFE6F0FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isMango ? const Color(0xFFCCE8B5) : const Color(0xFFBDD8F2),
                    ),
                  ),
                  child: Icon(
                    isMango ? Icons.eco_rounded : Icons.grass_rounded,
                    color: isMango ? AppColors.primary : const Color(0xFF1E6091),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: TextStyle(
                          fontFamily: AppFonts.heading(language),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        strings.diseaseRecords(count),
                        style: TextStyle(
                          fontFamily: AppFonts.body(language),
                          color: AppColors.textMedium,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernFeaturedDiseaseCard extends StatelessWidget {
  const _ModernFeaturedDiseaseCard({
    required this.disease,
    required this.language,
  });

  final Disease disease;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
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
                        Colors.black.withValues(alpha: 0.78),
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
                        style: TextStyle(
                          fontFamily: AppFonts.heading(language),
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings(language).localizedRisk(disease.severity),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.forest),
    );
  }
}
