import '../core/app_language.dart';
import '../core/app_strings.dart';

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
    required this.recommendationSummary,
    required this.actionUrgency,
    required this.economicImpact,
    required this.economicThresholdAction,
    required this.recurrenceRisk,
    required this.resistanceNotes,
    required this.ipmScore,
    required this.preHarvestIntervalDays,
    required this.favorableConditions,
    required this.stageBasedManagement,
    required this.progressionStages,
    required this.possibleCoInfections,
    required this.falsePositiveTriggers,
    required this.mlFocusRegions,
    required this.treatmentCostEstimate,
    required this.sindhiContent,
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
  final String recommendationSummary;
  final String actionUrgency;
  final String economicImpact;
  final String economicThresholdAction;
  final String recurrenceRisk;
  final String resistanceNotes;
  final int ipmScore;
  final int preHarvestIntervalDays;
  final FavorableConditions favorableConditions;
  final StageBasedManagement stageBasedManagement;
  final List<String> progressionStages;
  final List<String> possibleCoInfections;
  final List<String> falsePositiveTriggers;
  final List<String> mlFocusRegions;
  final String treatmentCostEstimate;
  final SindhiDiseaseContent? sindhiContent;

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
      recommendationSummary: json['recommendation_summary'] as String? ?? '',
      actionUrgency: json['action_urgency'] as String? ?? 'Monitor',
      economicImpact: json['economic_impact'] as String? ?? 'Medium',
      economicThresholdAction:
          json['economic_threshold_action'] as String? ?? '',
      recurrenceRisk: json['recurrence_risk'] as String? ?? 'Medium',
      resistanceNotes: json['resistance_notes'] as String? ?? '',
      ipmScore: (json['ipm_score'] as num?)?.toInt() ?? 0,
      preHarvestIntervalDays:
          (json['pre_harvest_interval_days'] as num?)?.toInt() ?? 0,
      favorableConditions: FavorableConditions.fromJson(
        json['favorable_conditions'] as Map<String, dynamic>? ?? const {},
      ),
      stageBasedManagement: StageBasedManagement.fromJson(
        json['stage_based_management'] as Map<String, dynamic>? ?? const {},
      ),
      progressionStages: _stringListOrEmpty(json['progression_stages']),
      possibleCoInfections: _stringListOrEmpty(json['possible_co_infections']),
      falsePositiveTriggers: _stringListOrEmpty(
        json['false_positive_triggers'],
      ),
      mlFocusRegions: _stringListOrEmpty(json['ml_focus_regions']),
      treatmentCostEstimate: json['treatment_cost_estimate'] as String? ?? '',
      sindhiContent: SindhiDiseaseContent.maybeFromJson(
        json['sd'] as Map<String, dynamic>?,
      ),
    );
  }

  String localizedName(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.name ?? nameSd) : name;

  List<String> localizedSymptoms(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.symptoms ?? symptomsSd) : symptoms;

  List<String> localizedCauses(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.causes ?? causesSd) : causes;

  List<String> localizedPrevention(AppLanguage language) => language.isSindhi
      ? (sindhiContent?.prevention ?? preventionSd)
      : prevention;

  List<String> localizedTreatment(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.treatment ?? treatmentSd) : treatment;

  String localizedOverview(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.overview ?? '') : '';

  String localizedImportantNote(AppLanguage language) =>
      language.isSindhi ? (sindhiContent?.importantNote ?? '') : '';

  String localizedRecommendationSummary(AppLanguage language) {
    if (!language.isSindhi) return recommendationSummary;
    return sindhiContent?.importantNote ?? recommendationSummary;
  }

  List<String> localizedProgressionStages(AppLanguage language) {
    if (!language.isSindhi) return progressionStages;
    return progressionStages
        .map(
          (stage) => _localizeTechnicalPhrase(
            stage
                .replaceAll('Stage 1:', 'مرحلو 1:')
                .replaceAll('Stage 2:', 'مرحلو 2:')
                .replaceAll('Stage 3:', 'مرحلو 3:')
                .replaceAll(
                  'small spots or mild discoloration',
                  'ننڍا داغ يا هلڪو رنگ بدلجڻ',
                )
                .replaceAll(
                  'lesion expansion and visible tissue damage',
                  'داغ وڌڻ ۽ پن جو حصو خراب ٿيڻ',
                )
                .replaceAll(
                  'tissue necrosis, leaf drop, or fruit/flower damage',
                  'حصو سڙڻ، پن ڪرڻ يا گل/ميوي کي نقصان',
                ),
          ),
        )
        .toList();
  }

  List<String> localizedCoInfections(AppLanguage language) {
    if (!language.isSindhi) return possibleCoInfections;
    return possibleCoInfections
        .map(
          (item) => _localizeDiseaseNames(item.replaceAll(' + ', ' سان گڏ ')),
        )
        .toList();
  }

  List<String> localizedFalsePositiveTriggers(AppLanguage language) {
    if (!language.isSindhi) return falsePositiveTriggers;
    return falsePositiveTriggers.map(_localizeTechnicalPhrase).toList();
  }

  List<String> localizedMlFocusRegions(AppLanguage language) {
    if (!language.isSindhi) return mlFocusRegions;
    return mlFocusRegions.map(_localizeTechnicalPhrase).toList();
  }

  List<String> localizedStageItems(List<String> items, AppLanguage language) {
    if (!language.isSindhi) return items;
    return items.map(_localizeTechnicalPhrase).toList();
  }

  String localizedResistanceNotes(AppLanguage language) {
    if (!language.isSindhi) return resistanceNotes;
    if (resistanceNotes.isEmpty) return '';
    return 'ساڳي دوا بار بار استعمال ڪرڻ سان بيماري يا جيت دوا جي عادت پئجي سگهي ٿي. دوا بدلائي استعمال ڪريو ۽ غير ضروري ڇڻڪار کان پاسو ڪريو.';
  }

  String localizedEconomicThresholdAction(AppLanguage language) {
    if (!language.isSindhi) return economicThresholdAction;
    if (id == 'mango_healthy') {
      return 'دوا جي ضرورت ناهي. هفتي وار نگراني جاري رکو.';
    }
    if (id.contains('weevil') || id.contains('midge')) {
      return 'جيت مار دوا تڏهن استعمال ڪريو جڏهن تازو نقصان وڌي رهيو هجي ۽ جيت جي موجودگي پڪ ٿي وڃي.';
    }
    return 'جيڪڏهن پنن يا نئين واڌ جو ڏهه سيڪڙو کان وڌيڪ حصو متاثر هجي، يا مينهن کان پوءِ بيماري وڌي رهي هجي، تڏهن علاج شروع ڪريو.';
  }

  String _localizeTechnicalPhrase(String value) {
    return _localizeDiseaseNames(value)
        .replaceAll('field scouting and sanitation', 'کيت جو معائنو ۽ صفائي')
        .replaceAll('neem or soft control', 'نيم يا نرم ضابطو')
        .replaceAll('selective insecticide', 'چونڊيل جيت مار دوا')
        .replaceAll('sucking pest control', 'چوسيندڙ جيتن تي ضابطو')
        .replaceAll('fungicide alone', 'صرف ڦڦوند مار دوا')
        .replaceAll('sanitation and pruning', 'صفائي ۽ ڇانٽ')
        .replaceAll('no treatment', 'دوا جي ضرورت ناهي')
        .replaceAll('unnecessary pesticide', 'غير ضروري دوا')
        .replaceAll('wind damage', 'هوا سبب نقصان')
        .replaceAll('pruning cuts', 'ڇانٽ جا ڪٽ')
        .replaceAll('mechanical tearing', 'مشيني يا هٿ سان ڦاٽڻ')
        .replaceAll('herbicide drift', 'گاهه مار دوا جو اڏامي لڳڻ')
        .replaceAll('heat stress leaf curling', 'گرمي سبب پن مڙڻ')
        .replaceAll('nutrient imbalance', 'غذا جو عدم توازن')
        .replaceAll(
          'very early disease without visible symptoms',
          'بيماري جي تمام شروعاتي حالت، جنهن ۾ نشان صاف نظر نه اچن',
        )
        .replaceAll('camera too far from leaf', 'فون پن کان گهڻو پري هجڻ')
        .replaceAll(
          'washed-out image hiding small lesions',
          'تمام روشن تصوير جنهن ۾ ننڍا داغ لڪي وڃن',
        )
        .replaceAll(
          'small feeding marks or tender flush damage',
          'کاڌل ننڍا نشان يا نرم نئين واڌ کي نقصان',
        )
        .replaceAll(
          'visible galls, holes, or cut shoots increase',
          'گال، سوراخ يا ڪٽيل ٽاريون وڌڻ',
        )
        .replaceAll(
          'new growth loss and reduced canopy development',
          'نئين واڌ گهٽجڻ ۽ وڻ جي وڌڻ ۾ گهٽتائي',
        )
        .replaceAll(
          'healthy uniform leaf color',
          'پن جو هڪجهڙو صحتمند سائو رنگ',
        )
        .replaceAll(
          'continue monitoring for small spots or discoloration',
          'ننڍن داغن يا رنگ بدلجڻ لاءِ نگراني جاري رکو',
        )
        .replaceAll(
          'rescan if visible symptoms appear',
          'صاف علامتون ظاهر ٿين ته ٻيهر جانچ ڪريو',
        )
        .replaceAll(
          'slight leaf curling or vein changes',
          'پن جو ٿورو مڙڻ يا رڳن ۾ تبديلي',
        )
        .replaceAll(
          'clear vein thickening and plant stunting',
          'رڳن جو صاف ٿلهو ٿيڻ ۽ ٻوٽي جو ننڍو رهڻ',
        )
        .replaceAll(
          'severe stunting and yield loss',
          'ٻوٽي جو سخت ننڍو رهڻ ۽ پيداوار گهٽجڻ',
        )
        .replaceAll(
          'small spindle or diamond-shaped lesions',
          'ننڍا هيري يا ڀالي جهڙا داغ',
        )
        .replaceAll(
          'lesions expand with gray center and brown border',
          'داغ وڌي ڀورو وچ ۽ ناسي ڪنارو ٺاهين ٿا',
        )
        .replaceAll(
          'neck blast or panicle damage reduces grain filling',
          'ڳچي يا سنگ کي نقصان، جنهن سان داڻو ڀرڻ گهٽجي ٿو',
        )
        .replaceAll('water-soaked leaf spots', 'پنن تي پاڻي جهڙا داغ')
        .replaceAll(
          'brown lesions expand with white growth under leaves',
          'ناسي داغ وڌن ٿا ۽ پنن هيٺ اڇي واڌ نظر اچي ٿي',
        )
        .replaceAll(
          'rapid leaf collapse and fruit rot',
          'پن جلدي سڙن ٿا ۽ ميوو خراب ٿئي ٿو',
        )
        .replaceAll(
          'poor focus or motion blur',
          'تصوير صاف نه هجڻ يا ڌنڌلي هجڻ',
        )
        .replaceAll('dust accumulation on leaves', 'پنن تي ڌوڙ يا مٽي گڏ ٿيڻ')
        .replaceAll('sun glare or harsh shadows', 'تيز سج جي چمڪ يا سخت ڇانو')
        .replaceAll('nutrient deficiency spots', 'غذا جي کوٽ سبب داغ')
        .replaceAll('old mechanical injury', 'پراڻو زخمي نشان')
        .replaceAll('sun scorch', 'سج سبب پن ساڙجڻ')
        .replaceAll('leaf center', 'پن جو وچ')
        .replaceAll('leaf margin', 'پن جو ڪنارو')
        .replaceAll('lesion border', 'داغ جو ڪنارو')
        .replaceAll('underside if visible', 'پن جي هيٺئين پاسي، جيڪڏهن نظر اچي')
        .replaceAll('shoot tip', 'ٽاري جو ڇيڙو')
        .replaceAll('stem junction', 'ٽاري ۽ ٿڙ جو ڳانڍاپو')
        .replaceAll('new flush', 'نئين واڌ')
        .replaceAll('leaf petiole', 'پن جو ڏنڊو')
        .replaceAll(
          'Scout field and confirm symptoms on multiple plants',
          'کيت ڏسي ڪيترن ٻوٽن تي علامتون پڪ ڪريو',
        )
        .replaceAll(
          'Remove visibly infected leaves or plant debris where practical',
          'جتي ممڪن هجي بيمار پن يا ڪچرو هٽايو',
        )
        .replaceAll(
          'Improve airflow, irrigation timing, and field sanitation',
          'هوا جو گذر، پاڻي ڏيڻ جو وقت ۽ صفائي بهتر ڪريو',
        )
        .replaceAll(
          'Use recommended chemical control with PPE and local agriculture advice',
          'حفاظتي سامان سان مقامي زرعي صلاح موجب دوا استعمال ڪريو',
        )
        .replaceAll(
          'Apply IPM measures and use recommended treatment only if symptoms are spreading',
          'گڏيل بچاءَ جا طريقا اختيار ڪريو ۽ دوا رڳو تڏهن ڏيو جڏهن علامتون وڌي رهيون هجن',
        )
        .replaceAll(
          'Apply selective insecticide only if pest damage is increasing',
          'چونڊيل جيت مار دوا رڳو تڏهن استعمال ڪريو جڏهن جيت جو نقصان وڌي رهيو هجي',
        )
        .replaceAll(
          'Apply چونڊيل جيت مار دوا only if pest damage is increasing',
          'چونڊيل جيت مار دوا رڳو تڏهن استعمال ڪريو جڏهن جيت جو نقصان وڌي رهيو هجي',
        )
        .replaceAll(
          'Avoid broad-spectrum sprays during flowering and protect beneficial insects',
          'گل اچڻ وقت سخت عام ڇڻڪار کان پاسو ڪريو ۽ فائديمند جيتن کي بچايو',
        )
        .replaceAll('Continue weekly scouting', 'هفتي وار فصل جو معائنو جاري رکو')
        .replaceAll(
          'Control vector pressure and avoid planting near infected fields',
          'بيماري کڻندڙ جيتن تي ضابطو ڪريو ۽ بيمار کيت ڀرسان پوک کان پاسو ڪريو',
        )
        .replaceAll(
          'Do not rely on curative spray; rogue badly infected plants',
          'علاج واري ڇڻڪار تي ڀروسو نه ڪريو؛ تمام بيمار ٻوٽا ڪڍي ڇڏيو',
        )
        .replaceAll(
          'Isolate or remove heavily infected plant material',
          'تمام بيمار ٻوٽي وارو مواد الڳ يا ختم ڪريو',
        )
        .replaceAll(
          'Maintain balanced irrigation and nutrition',
          'پاڻي ۽ خوراڪ جو توازن برقرار رکو',
        )
        .replaceAll(
          'Manage whitefly using IPM and tolerant varieties',
          'گڏيل بچاءَ ۽ برداشت ڪندڙ قسمن سان سفيد مک تي ضابطو ڪريو',
        )
        .replaceAll('No disease action needed', 'بيماري لاءِ دوا يا خاص عمل جي ضرورت ناهي')
        .replaceAll(
          'No severe disease management required unless new symptoms appear',
          'نئين علامتن کان سواءِ سخت علاج جي ضرورت ناهي',
        )
        .replaceAll(
          'Remove damaged shoots or leaves where practical',
          'جتي ممڪن هجي خراب ٽاريون يا پن هٽايو',
        )
        .replaceAll(
          'Remove heavily infected young plants if spread is increasing',
          'بيماري وڌي رهي هجي ته تمام بيمار ننڍا ٻوٽا ڪڍي ڇڏيو',
        )
        .replaceAll(
          'Remove infected volunteer plants',
          'پاڻمرادو ڦٽل بيمار ٻوٽا هٽايو',
        )
        .replaceAll(
          'Scout new flush and confirm active pest presence',
          'نئين واڌ جو معائنو ڪريو ۽ جيت جي موجودگي پڪ ڪريو',
        )
        .replaceAll(
          'Start whitefly monitoring with sticky traps',
          'چپڪندڙ ڦندن سان سفيد مک جي نگراني شروع ڪريو',
        )
        .replaceAll(
          'Treat affected block based on local threshold',
          'متاثر حصي ۾ مقامي حد موجب علاج ڪريو',
        )
        .replaceAll(
          'Use traps, sanitation, and conserve natural enemies',
          'ڦندا لڳايو، صفائي رکو ۽ فائديمند جيتن کي بچايو',
        )
        .replaceAll('boll opening', 'بول جو کليل حصو')
        .replaceAll('boll surface', 'بول جي سطح')
        .replaceAll('infected lint area', 'متاثر روئي وارو حصو')
        .replaceAll('leaf veins', 'پن جون رڳون')
        .replaceAll('neck/panicle area', 'ڳچي يا سنگ وارو حصو')
        .replaceAll(
          'new growth tip',
          'نئين واڌ جو ڇيڙو',
        );
  }

  String _localizeDiseaseNames(String value) {
    return value
        .replaceAll('Anthracnose', 'اينٿراڪنوز')
        .replaceAll('Powdery mildew', 'اڇي ڦڦوند')
        .replaceAll('Powdery Mildew', 'اڇي ڦڦوند')
        .replaceAll('Sooty mould', 'ڪاري ڦڦوند')
        .replaceAll('Sooty Mould', 'ڪاري ڦڦوند')
        .replaceAll('Bacterial canker', 'بيڪٽيريل ڪينڪر')
        .replaceAll('Leaf spot complex', 'پنن جي داغن واري بيماري')
        .replaceAll('secondary pest damage', 'ٻئي جيت جو نقصان')
        .replaceAll('hopper/mealybug infestation', 'هاپر يا ميلي بگ جو حملو')
        .replaceAll('Rust', 'رتيءَ واري بيماري')
        .replaceAll('leaf spot complex', 'پنن جي داغن واري بيماري')
        .replaceAll('Leaf curl virus', 'پن مڙڻ وارو وائرس')
        .replaceAll('whitefly infestation', 'سفيد مک جو حملو')
        .replaceAll('Boll rot', 'بول جو ساڙ')
        .replaceAll('bollworm damage', 'بول ورم جو نقصان')
        .replaceAll('Rice blast', 'چانورن جو بلاسٽ')
        .replaceAll('brown spot', 'ناسي داغ')
        .replaceAll('sheath blight', 'شيٿ بلائٽ')
        .replaceAll('Late blight', 'دير سان ساڙيندڙ بيماري')
        .replaceAll('early blight', 'جلدي ساڙيندڙ بيماري')
        .replaceAll('bacterial spot', 'بيڪٽيريل داغ')
        .replaceAll(
          'None expected; rescan if symptoms appear',
          'گڏيل بيماري جو امڪان ناهي؛ علامتون ظاهر ٿين ته ٻيهر جانچ ڪريو',
        );
  }

  static List<String> _stringList(dynamic value) {
    return (value as List<dynamic>).map((item) => item.toString()).toList();
  }

  static List<String> _stringListOrEmpty(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}

class SindhiDiseaseContent {
  const SindhiDiseaseContent({
    required this.name,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.prevention,
    required this.treatment,
    required this.importantNote,
  });

  final String name;
  final String overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> prevention;
  final List<String> treatment;
  final String importantNote;

  static SindhiDiseaseContent? maybeFromJson(Map<String, dynamic>? json) {
    final simple = json?['simple'];
    if (simple is! Map<String, dynamic>) return null;
    return SindhiDiseaseContent(
      name: simple['name'] as String? ?? '',
      overview: simple['overview'] as String? ?? '',
      symptoms: Disease._stringListOrEmpty(simple['symptoms']),
      causes: Disease._stringListOrEmpty(simple['causes']),
      prevention: Disease._stringListOrEmpty(simple['prevention']),
      treatment: Disease._stringListOrEmpty(simple['treatment']),
      importantNote: simple['important_note'] as String? ?? '',
    );
  }
}

class FavorableConditions {
  const FavorableConditions({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
  });

  final String temperature;
  final String humidity;
  final String rainfall;

  factory FavorableConditions.fromJson(Map<String, dynamic> json) {
    return FavorableConditions(
      temperature: json['temperature'] as String? ?? '',
      humidity: json['humidity'] as String? ?? '',
      rainfall: json['rainfall'] as String? ?? '',
    );
  }

  List<String> asList(AppStrings strings) {
    if (strings.language.isSindhi) {
      return [
        if (temperature.isNotEmpty) 'گرمي پد: ${_sdTemperature(temperature)}',
        if (humidity.isNotEmpty) 'گهم: ${_sdCondition(humidity)}',
        if (rainfall.isNotEmpty) 'مينهن: ${_sdCondition(rainfall)}',
      ];
    }
    return [
      if (temperature.isNotEmpty) 'Temperature: $temperature',
      if (humidity.isNotEmpty) 'Humidity: $humidity',
      if (rainfall.isNotEmpty) 'Rainfall: $rainfall',
    ];
  }

  String _sdCondition(String value) {
    return switch (value) {
      'High' => 'گهڻي',
      'Very high' => 'تمام گهڻي',
      'Medium' => 'وچولي',
      'Normal' => 'نارمل',
      'Medium to high' => 'وچولي کان گهڻي',
      'Frequent rain or leaf wetness' => 'بار بار مينهن يا پنن جو ڀڄڻ',
      'Frequent rain, dew, cloudy weather' =>
        'بار بار مينهن، اوس ۽ ابر واري موسم',
      'Frequent rain, fog, long leaf wetness' =>
        'بار بار مينهن، ڌنڌ ۽ پنن جو گهڻي دير ڀڄل رهڻ',
      'No disease-favorable warning' => 'بيماري وڌڻ لاءِ خاص خطرو ناهي',
      _ => value,
    };
  }

  String _sdTemperature(String value) {
    return value.replaceAll('°C', ' ڊگري سينٽي گريڊ');
  }
}

class StageBasedManagement {
  const StageBasedManagement({
    required this.early,
    required this.moderate,
    required this.severe,
  });

  final List<String> early;
  final List<String> moderate;
  final List<String> severe;

  factory StageBasedManagement.fromJson(Map<String, dynamic> json) {
    return StageBasedManagement(
      early: Disease._stringListOrEmpty(json['early']),
      moderate: Disease._stringListOrEmpty(json['moderate']),
      severe: Disease._stringListOrEmpty(json['severe']),
    );
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

  String localizedDose(AppLanguage language) {
    if (!language.isSindhi) return dose;
    return dose
        .replaceAll(
          'Use label dose for sucking pests',
          'چوسيندڙ جيتن لاءِ لکيل هدايت موجب مقدار استعمال ڪريو',
        )
        .replaceAll(
          'Use label dose for whitefly',
          'سفيد مک لاءِ لکيل هدايت موجب مقدار استعمال ڪريو',
        )
        .replaceAll('Use label dose', 'لکيل هدايت موجب مقدار استعمال ڪريو')
        .replaceAll(
          'Use only with local extension advice',
          'صرف مقامي زرعي صلاح سان استعمال ڪريو',
        )
        .replaceAll('Maintain good crop care', 'فصل جي سٺي سنڀال جاري رکو')
        .replaceAll('No medicine needed', 'دوا جي ضرورت ناهي')
        .replaceAll('per liter water', 'في ليٽر پاڻي')
        .replaceAll('g ', 'گرام ')
        .replaceAll('ml ', 'ايم ايل ');
  }
}
