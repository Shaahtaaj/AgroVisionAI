import 'app_language.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get _sd => language.isSindhi;

  String get appName => 'AgroVision AI';
  String get tagLine =>
      _sd ? 'فصلن جي بيماري جي سڃاڻپ' : 'Smart Agro Disease Detection';
  String get selectLanguage => _sd ? 'ٻولي چونڊيو' : 'Select language';
  String get continueText => _sd ? 'شروع ڪريو' : 'Continue';
  String get home => _sd ? 'گھر' : 'Home';
  String get crops => _sd ? 'فصل' : 'Crops';
  String get scanLeaf => _sd ? 'پن اسڪين ڪريو' : 'Scan leaf';
  String get diseaseInfo => _sd ? 'بيماري ڄاڻ' : 'Disease info';
  String get symptoms => _sd ? 'علامتون' : 'Symptoms';
  String get causes => _sd ? 'سبب' : 'Causes';
  String get prevention => _sd ? 'بچاء' : 'Prevention';
  String get treatment => _sd ? 'علاج' : 'Treatment';
  String get medicines => _sd ? 'زرعي دوائون' : 'Agricultural medicines';
  String get confidence => _sd ? 'اعتماد' : 'Confidence';
  String get result => _sd ? 'نتيجو' : 'Result';
  String get camera => _sd ? 'ڪيمرا' : 'Camera';
  String get gallery => _sd ? 'گيلري' : 'Gallery';
  String get processing =>
      _sd ? 'تصوير چڪاس ٿي رهي آهي...' : 'Analyzing leaf image...';
  String get chooseImage =>
      _sd ? 'تصوير چونڊيو يا ڪيمرا کوليو' : 'Capture or choose a leaf image';
  String get mangoOnly =>
      _sd ? 'AI ماڊل هن وقت انب لاءِ آهي' : 'AI model currently supports mango';
  String get noMatch => _sd
      ? 'هن بيماري جي مقامي ڄاڻ موجود ناهي'
      : 'Local details for this class are not available yet';
  String get retry => _sd ? 'ٻيهر ڪوشش' : 'Try again';
  String get details => _sd ? 'تفصيل' : 'Details';
  String get classifierLibrary =>
      _sd ? 'انب ڪلاسيفائر لائبريري' : 'Mango classifier library';
  String get classifierBody => _sd
      ? 'انب جي پنن کي سڃاڻو، علامتون ڏسو، ۽ مناسب زرعي قدم چونڊيو.'
      : 'Classify mango leaves, review symptoms, and choose safer field actions.';
  String get offlineGuide =>
      _sd ? 'آف لائن AI + مقامي گائيڊ' : 'Offline AI + Local Guide';
  String get about => _sd ? 'اسان جي باري ۾' : 'About';
  String get developer => _sd ? 'ڊولپر' : 'Developer';
  String get developerName => _sd ? 'شاھ تاج' : 'Shah Taj';
  String get developerRole => _sd ? 'ويب ايپ ڊولپر' : 'Web App Developer';
  String get finalYearProject =>
      _sd ? 'فائنل ايئر پروجيڪٽ' : 'Final Year Project';
  String get vision => _sd ? 'اسان جو مقصد' : 'Our Vision';
  String get aboutBody => _sd
      ? 'اسان جو مقصد سنڌ جي ھاريءَ کي وڌيڪ سولي انداز ۾ فصل کي پوکڻ، ان کي سُٺي نموني پرکڻ ۽ جانچڻ ۾ مدد مھيا ڪرڻ آھي، ھن جديديت پڄاڻان دورَ ۾ ان پاسي تي بہ سوچڻ ويچارڻ ۽ ان تي ڪم ڪرڻ جي ضرورت آھي.\n\nاسان جو ھي پروجيڪٽ فائنل ايئر جو آھي پر ان کي اڃان اڳتي کڻي ھلنداسين ۽ بھتر کان بھتر بنائينداسين.'
      : 'Our goal is to help the farmers of Sindh grow crops more easily and support them in properly observing, checking, and evaluating their fields. In this modern era, it is important to think about this direction and continue working on practical agricultural technology.\n\nThis project is our final year project, but we will continue taking it forward and keep improving it step by step.';
  String get reliability => _sd ? 'نتيجي جي اعتبار' : 'Result reliability';
  String get reliable => _sd ? 'قابل اعتماد' : 'Reliable';
  String get possible => _sd ? 'ممڪن' : 'Possible';
  String get uncertain => _sd ? 'غير يقيني' : 'Uncertain';
  String get qualityCheck => _sd ? 'تصوير جي معيار' : 'Image quality';
  String get qualityGood =>
      _sd ? 'تصوير مناسب لڳي ٿي.' : 'Image quality looks usable.';
  String get uncertainAdvice => _sd
      ? 'اعتماد گهٽ آهي. صاف، ويجهي ۽ روشن تصوير سان ٻيهر اسڪين ڪريو.'
      : 'Confidence is low. Retake a clear, close, well-lit leaf photo before using this result.';
  String get possibleAdvice => _sd
      ? 'هي نتيجو ممڪن آهي. علاج کان اڳ پنن جون علامتون ملائي ڏسو.'
      : 'This result is possible. Match the visible symptoms before taking treatment action.';
  String get reliableAdvice => _sd
      ? 'نتيجو مناسب اعتماد سان مليو آهي، پوءِ بہ فيلڊ حالتن سان ملائي ڏسو.'
      : 'The result has good confidence, but still compare it with field symptoms.';
  String get safetyNote => _sd
      ? 'حفاظتي نوٽ: دوا هميشه ليبل، مقامي زرعي ماهر، موسم ۽ فصل جي حالت مطابق استعمال ڪريو. غير ضروري اسپري کان پاسو ڪريو.'
      : 'Safety note: Always use medicines according to the label, local agriculture advice, weather, and crop condition. Avoid unnecessary spraying.';
  String get feedback => _sd ? 'ڇا نتيجو صحيح هو؟' : 'Was this result correct?';
  String get correct => _sd ? 'صحيح' : 'Correct';
  String get wrong => _sd ? 'غلط' : 'Wrong';
  String get notSure => _sd ? 'پڪ ناهي' : 'Not sure';
  String get thanksFeedback => _sd
      ? 'مهرباني، توهان جي راءِ محفوظ ٿي وئي.'
      : 'Thanks, your feedback was saved.';
  String get lowResolutionWarning => _sd
      ? 'تصوير جي ريزوليوشن گهٽ آهي. پن جي ويجهي ۽ صاف تصوير وٺو.'
      : 'Image resolution is low. Capture a closer, clearer leaf photo.';
  String get darkImageWarning => _sd
      ? 'تصوير اونداھي لڳي ٿي. بهتر روشني ۾ تصوير وٺو.'
      : 'Image looks dark. Take the photo in better light.';
  String get brightImageWarning => _sd
      ? 'تصوير تمام گهڻي روشن آهي. سڌي تيز سج کان پاسو ڪريو.'
      : 'Image looks overexposed. Avoid direct harsh sunlight.';
  String get blurryImageWarning => _sd
      ? 'تصوير ڌنڌلي لڳي ٿي. فون کي سڌو رکو ۽ پن تي فوڪس ڪريو.'
      : 'Image may be blurry. Keep the phone steady and focus on the leaf.';
}
