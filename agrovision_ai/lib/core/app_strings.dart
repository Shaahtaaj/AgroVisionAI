import 'app_language.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get _sd => language.isSindhi;

  String get appName => _sd ? 'ايگرو ويزن' : 'AgroVision AI';
  String get tagLine =>
      _sd ? 'فصلن جي بيماري جي سڃاڻپ' : 'Smart Agro Disease Detection';
  String get selectLanguage => _sd ? 'ٻولي چونڊيو' : 'Select language';
  String get continueText => _sd ? 'شروع ڪريو' : 'Continue';
  String get home => _sd ? 'گھر' : 'Home';
  String get crops => _sd ? 'فصل' : 'Crops';
  String get scanLeaf => _sd ? 'پن جانچيو' : 'Scan leaf';
  String get diseaseInfo => _sd ? 'بيمارين جي ڄاڻ' : 'Disease info';
  String get symptoms => _sd ? 'علامتون' : 'Symptoms';
  String get causes => _sd ? 'سبب' : 'Causes';
  String get prevention => _sd ? 'بچاءُ' : 'Prevention';
  String get treatment => _sd ? 'علاج' : 'Treatment';
  String get medicines => _sd ? 'زرعي دوائون' : 'Agricultural medicines';
  String get confidence => _sd ? 'يقين' : 'Confidence';
  String get result => _sd ? 'نتيجو' : 'Result';
  String get camera => _sd ? 'تصوير وٺو' : 'Camera';
  String get gallery => _sd ? 'تصوير چونڊيو' : 'Gallery';
  String get processing =>
      _sd ? 'تصوير چڪاس ٿي رهي آهي...' : 'Analyzing leaf image...';
  String get chooseImage =>
      _sd ? 'تصوير وٺو يا چونڊيو' : 'Capture or choose a leaf image';
  String get mangoOnly =>
      _sd ? 'في الحال سڃاڻپ صرف انب لاءِ آهي' : 'AI model currently supports mango';
  String get noMatch => _sd
      ? 'هن بيماري جي مقامي ڄاڻ موجود ناهي'
      : 'Local details for this class are not available yet';
  String get retry => _sd ? 'ٻيهر ڪوشش' : 'Try again';
  String get details => _sd ? 'تفصيل' : 'Details';
  String get classifierLibrary =>
      _sd ? 'انب جي بيمارين جي ڄاڻ' : 'Mango classifier library';
  String get classifierBody => _sd
      ? 'انب جي پنن کي سڃاڻو، علامتون ڏسو، ۽ مناسب زرعي قدم چونڊيو.'
      : 'Classify mango leaves, review symptoms, and choose safer field actions.';
  String get offlineGuide =>
      _sd ? 'بنا نيٽ جي مقامي رهنمائي' : 'Offline AI + Local Guide';
  String get about => _sd ? 'اسان جي باري ۾' : 'About';
  String get developer => _sd ? 'ڊولپر' : 'Developer';
  String get developerName => _sd ? 'شاھ تاج' : 'Shah Taj';
  String get developerRole => 'ويب ايپ ڊولپر';
  String get finalYearProject =>
      _sd ? 'فائنل ايئر پروجيڪٽ' : 'Final Year Project';
  String get vision => _sd ? 'اسان جو مقصد' : 'Our Vision';
  String get aboutBody => _sd
      ? 'اسان جو مقصد سنڌ جي ھاريءَ کي وڌيڪ سولي انداز ۾ فصل کي پوکڻ، ان کي سُٺي نموني پرکڻ ۽ جانچڻ ۾ مدد مھيا ڪرڻ آھي، ھن جديديت پڄاڻان دورَ ۾ ان پاسي تي بہ سوچڻ ويچارڻ ۽ ان تي ڪم ڪرڻ جي ضرورت آھي.\n\nاسان جو ھي پروجيڪٽ فائنل ايئر جو آھي پر ان کي اڃان اڳتي کڻي ھلنداسين ۽ بھتر کان بھتر بنائينداسين.'
      : 'Our goal is to help the farmers of Sindh grow crops more easily and support them in properly observing, checking, and evaluating their fields. In this modern era, it is important to think about this direction and continue working on practical agricultural technology.\n\nThis project is our final year project, but we will continue taking it forward and keep improving it step by step.';
  String get reliability => _sd ? 'نتيجي تي ڀروسو' : 'Result reliability';
  String get reliable => _sd ? 'قابل اعتماد' : 'Reliable';
  String get possible => _sd ? 'ممڪن' : 'Possible';
  String get uncertain => _sd ? 'غير يقيني' : 'Uncertain';
  String get qualityCheck => _sd ? 'تصوير جي معيار' : 'Image quality';
  String get qualityGood =>
      _sd ? 'تصوير مناسب لڳي ٿي.' : 'Image quality looks usable.';
  String get uncertainAdvice => _sd
      ? 'يقين گهٽ آهي. صاف، ويجهي ۽ روشن تصوير سان ٻيهر جانچ ڪريو.'
      : 'Confidence is low. Retake a clear, close, well-lit leaf photo before using this result.';
  String get possibleAdvice => _sd
      ? 'هي نتيجو ممڪن آهي. علاج کان اڳ پنن جون علامتون ملائي ڏسو.'
      : 'This result is possible. Match the visible symptoms before taking treatment action.';
  String get reliableAdvice => _sd
      ? 'نتيجو مناسب مليو آهي، پوءِ بہ زمين جي حالتن سان ڀيٽ ڪري ڏسو.'
      : 'The result has good confidence, but still compare it with field symptoms.';
  String get safetyNote => _sd
      ? 'حفاظتي نوٽ: دوا هميشه لکيل هدايت، مقامي زرعي ماهر، موسم ۽ فصل جي حالت مطابق استعمال ڪريو. غير ضروري دوا ڇٽڻ کان پاسو ڪريو.'
      : 'Safety note: Always use medicines according to the label, local agriculture advice, weather, and crop condition. Avoid unnecessary spraying.';
  String get feedback => _sd ? 'ڇا نتيجو صحيح هو؟' : 'Was this result correct?';
  String get correct => _sd ? 'صحيح' : 'Correct';
  String get wrong => _sd ? 'غلط' : 'Wrong';
  String get notSure => _sd ? 'پڪ ناهي' : 'Not sure';
  String get thanksFeedback => _sd
      ? 'مهرباني، توهان جي راءِ محفوظ ٿي وئي.'
      : 'Thanks, your feedback was saved.';
  String get lowResolutionWarning => _sd
      ? 'تصوير صاف نه آهي. پن جي ويجهي ۽ چٽي تصوير وٺو.'
      : 'Image resolution is low. Capture a closer, clearer leaf photo.';
  String get darkImageWarning => _sd
      ? 'تصوير ڌنڌلي لڳي رھي آھي. بهتر روشني ۾ تصوير وٺو.'
      : 'Image looks dark. Take the photo in better light.';
  String get brightImageWarning => _sd
      ? 'تصوير تمام گهڻي روشن آهي. سڌي تيز سج کان پاسو ڪريو.'
      : 'Image looks overexposed. Avoid direct harsh sunlight.';
  String get blurryImageWarning => _sd
      ? 'تصوير ڌنڌلي لڳي ٿي. فون کي سڌو رکو ته پن صاف نظر اچي.'
      : 'Image may be blurry. Keep the phone steady and focus on the leaf.';
  String get quickAdvice => _sd ? 'فوري صلاح' : 'Quick advice';
  String get actionUrgency => _sd ? 'تڪڙو عمل' : 'Action urgency';
  String get ipmScore => _sd ? 'گڏيل بچاءَ جو درجو' : 'IPM score';
  String get economics => _sd ? 'خرچ ۽ نقصان' : 'Cost and impact';
  String get fieldConditions =>
      _sd ? 'موسم، گهم ۽ کيت جون حالتون' : 'Weather and field conditions';
  String get stageManagement =>
      _sd ? 'مرحلي موجب سنڀال' : 'Stage-based management';
  String get earlyStage => _sd ? 'شروعاتي' : 'Early';
  String get moderateStage => _sd ? 'وچولو' : 'Moderate';
  String get severeStage => _sd ? 'سخت' : 'Severe';
  String get progression => _sd ? 'بيماري وڌڻ جا مرحلا' : 'Symptom progression';
  String get diagnosticTips => _sd ? 'تشخيصي احتياط' : 'Diagnostic checks';
  String get coInfections =>
      _sd ? 'گڏيل بيماري جو امڪان' : 'Possible co-infections';
  String get falsePositiveRisks =>
      _sd ? 'غلط نتيجي جا سبب' : 'False positive risks';
  String get focusRegions =>
      _sd ? 'تصوير ۾ ڏسڻ وارا حصا' : 'Image focus regions';
  String get preHarvestInterval =>
      _sd ? 'فصل لهڻ کان اڳ وقفو' : 'Pre-harvest interval';
  String get days => _sd ? 'ڏينهن' : 'days';
  String get recurrenceRisk => _sd ? 'ٻيهر اچڻ جو خطرو' : 'Recurrence risk';
  String get resistanceNotes =>
      _sd ? 'دوا جي مزاحمت بابت نوٽ' : 'Resistance notes';
  String get searchKnowledge =>
      _sd ? 'بيماري يا فصل ڳوليو' : 'Search crop or disease';
  String get knowledgeHub => _sd ? 'علمي مرڪز' : 'Knowledge hub';
  String get agriWords => _sd ? 'زرعي لفظ' : 'Agri words';
  String get agriWordsSubtitle => _sd
      ? 'فصل، بيماري، گهم، ڇڻڪار ۽ زرعي دوا جا آسان مطلب'
      : 'Simple meanings for crop, disease, humidity, spray, and medicine terms';
  String get relatedAgriWords =>
      _sd ? 'لاڳاپيل زرعي لفظ' : 'Related agri words';
  String diseaseRecords(int count) =>
      _sd ? '$count بيمارين بابت ڄاڻون' : '$count disease records';
  String get imageSizeLabel => _sd ? 'تصوير' : 'AI input';
  String get languageCountLabel => _sd ? 'ٻوليون' : 'Languages';
  String get guideLabel => _sd ? 'رهنمائي' : 'Guide';
  String get offlineLabel => _sd ? 'بنا نيٽ' : 'Offline';
  String languageName(AppLanguage option) {
    if (!_sd) return option.label;
    return switch (option) {
      AppLanguage.english => 'انگريزي',
      AppLanguage.sindhi => 'سنڌي',
    };
  }

  String localizedUrgency(String value) {
    if (!_sd) return value;
    return switch (value) {
      'Immediate' => 'فوري',
      'Within 3 days' => 'ٽن ڏينهن اندر',
      'Monitor' => 'نگراني ڪريو',
      _ => value,
    };
  }

  String localizedRisk(String value) {
    if (!_sd) return value;
    return switch (value) {
      'High' => 'وڌيڪ',
      'Medium' => 'وچولو',
      'Low' => 'گهٽ',
      'High risk' => 'وڌيڪ خطرو',
      'Medium risk' => 'وچولو خطرو',
      'Pest alert' => 'جيت جو خطرو',
      'Healthy' => 'صحتمند',
      _ => value,
    };
  }
}
