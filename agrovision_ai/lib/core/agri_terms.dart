import 'app_language.dart';

class AgriTerm {
  const AgriTerm({
    required this.english,
    required this.sindhi,
    required this.definitionSd,
    required this.categorySd,
    required this.keywords,
  });

  final String english;
  final String sindhi;
  final String definitionSd;
  final String categorySd;
  final List<String> keywords;

  String title(AppLanguage language) => language.isSindhi ? sindhi : english;

  String subtitle(AppLanguage language) {
    if (language.isSindhi) return definitionSd;
    return '$sindhi - $definitionSd';
  }
}

class AgriTerms {
  const AgriTerms._();

  static const List<AgriTerm> all = [
    AgriTerm(
      english: 'Agriculture',
      sindhi: 'زراعت',
      definitionSd: 'فصل پوکڻ، سنڀالڻ ۽ پيداوار وٺڻ جو ڪم.',
      categorySd: 'زراعت ۽ کيتي',
      keywords: ['زراعت', 'زرعي', 'کيتي', 'پوک'],
    ),
    AgriTerm(
      english: 'Farmer',
      sindhi: 'هاري / آبادگار',
      definitionSd: 'فصل پوکيندڙ ۽ زمين سنڀاليندڙ ماڻهو.',
      categorySd: 'زراعت ۽ کيتي',
      keywords: ['هاري', 'آبادگار', 'ڪڙمي', 'ڪسان'],
    ),
    AgriTerm(
      english: 'Crop',
      sindhi: 'فصل',
      definitionSd: 'زمين ۾ پوکيل ٻوٽو، جيئن انب، ڪڻڪ، ڪپهه يا چانور.',
      categorySd: 'فصل',
      keywords: ['فصل', 'پوک', 'انب', 'ڪڻڪ', 'ڪپهه', 'چانور', 'ٽماٽو'],
    ),
    AgriTerm(
      english: 'Mango',
      sindhi: 'انب',
      definitionSd: 'سنڌ ۾ عام پوکجندڙ ميويدار وڻ ۽ فصل.',
      categorySd: 'فصل',
      keywords: ['انب', 'mango'],
    ),
    AgriTerm(
      english: 'Cotton',
      sindhi: 'ڪپهه / ڦٽي',
      definitionSd: 'روئي حاصل ڪرڻ وارو اهم فصل.',
      categorySd: 'فصل',
      keywords: ['ڪپهه', 'ڦٽي', 'cotton'],
    ),
    AgriTerm(
      english: 'Rice',
      sindhi: 'چانور / ساريون',
      definitionSd: 'پاڻي واري پوک ۾ ٿيندڙ اهم اناج وارو فصل.',
      categorySd: 'فصل',
      keywords: ['چانور', 'ساريون', 'rice'],
    ),
    AgriTerm(
      english: 'Fungus',
      sindhi: 'ڦڦوند',
      definitionSd:
          'اهڙو جراثيمي جاندار جيڪو گهم ۽ برساتي موسم ۾ فصل تي بيماري وڌائي سگهي ٿو.',
      categorySd: 'ٻوٽن جون بيماريون',
      keywords: ['ڦڦوند', 'fungus', 'مائلڊيو', 'داغ', 'ساڙ'],
    ),
    AgriTerm(
      english: 'Fungicide',
      sindhi: 'ڦڦوند مار دوا',
      definitionSd: 'ڦڦوند واري بيماري کي روڪڻ يا گهٽائڻ لاءِ استعمال ٿيندڙ دوا.',
      categorySd: 'زرعي دوائون',
      keywords: ['ڦڦوند مار دوا', 'مينڪوزيب', 'ڪاپر', 'سلفر'],
    ),
    AgriTerm(
      english: 'Insect',
      sindhi: 'جيت / ڪيڙو',
      definitionSd: 'فصل کي نقصان ڏيندڙ يا ڪڏهن فائديمند ننڍو جاندار.',
      categorySd: 'جيت ۽ آفتون',
      keywords: ['جيت', 'ڪيڙو', 'ويول', 'مک', 'هاپر', 'ميلي بگ'],
    ),
    AgriTerm(
      english: 'Pesticide',
      sindhi: 'جيت مار دوا',
      definitionSd:
          'فصل کي نقصان ڏيندڙ جيتن کي گهٽائڻ لاءِ دوا؛ ضرورت کان سواءِ استعمال نه ڪجي.',
      categorySd: 'زرعي دوائون',
      keywords: ['جيت مار دوا', 'insecticide', 'pesticide'],
    ),
    AgriTerm(
      english: 'Spray',
      sindhi: 'ڇڻڪار / ڦوهارو',
      definitionSd: 'دوا يا پاڻي کي بارڪ ڦوهاري جي صورت ۾ فصل تي ڏيڻ.',
      categorySd: 'زرعي ڪم',
      keywords: ['ڇڻڪار', 'ڦوهارو', 'دوا ڇٽڻ'],
    ),
    AgriTerm(
      english: 'Humidity',
      sindhi: 'گهم / آلاڻ',
      definitionSd:
          'هوا يا ماحول ۾ آلاڻ؛ گهڻي گهم سان ڪيتريون بيماريون وڌن ٿيون.',
      categorySd: 'موسم ۽ وڌڻ جون حالتون',
      keywords: ['گهم', 'آلاڻ', 'پوسل', 'humidity'],
    ),
    AgriTerm(
      english: 'Irrigation',
      sindhi: 'آبپاشي',
      definitionSd: 'فصل کي ضرورت مطابق پاڻي ڏيڻ جو عمل.',
      categorySd: 'مٽي ۽ آبپاشي',
      keywords: ['آبپاشي', 'پاڻي', 'ريج'],
    ),
    AgriTerm(
      english: 'Soil',
      sindhi: 'مٽي / زمين',
      definitionSd: 'فصل جي پاڙن لاءِ بنيادي جڳهه، جنهن مان ٻوٽو خوراڪ وٺي ٿو.',
      categorySd: 'مٽي ۽ آبپاشي',
      keywords: ['مٽي', 'زمين', 'پاڙ'],
    ),
    AgriTerm(
      english: 'Orchard',
      sindhi: 'باغ / ميون جو باغ',
      definitionSd: 'ميويدار وڻن وارو پوکيل علائقو.',
      categorySd: 'زراعت ۽ کيتي',
      keywords: ['باغ', 'ميون جو باغ', 'انب'],
    ),
    AgriTerm(
      english: 'Rust disease',
      sindhi: 'رتيءَ جي بيماري',
      definitionSd: 'پنن تي زنگ يا رتي رنگ جهڙا ڦٽ پيدا ڪندڙ بيماري.',
      categorySd: 'ٻوٽن جون بيماريون',
      keywords: ['رتيءَ', 'زنگ', 'ڪڻڪ'],
    ),
    AgriTerm(
      english: 'Fruit rot',
      sindhi: 'ميوي جو ساڙ',
      definitionSd: 'ميوي جو نرم، ناسي يا ڪارو ٿي خراب ٿيڻ.',
      categorySd: 'ٻوٽن جون بيماريون',
      keywords: ['روٽ', 'ساڙ', 'ميوو', 'بول'],
    ),
    AgriTerm(
      english: 'Biological control',
      sindhi: 'حياتياتي ضابطو',
      definitionSd: 'هاڃيڪار جيتن کي قدرتي دشمنن يا محفوظ طريقن سان گهٽائڻ.',
      categorySd: 'جيت ۽ آفتون',
      keywords: ['حياتياتي ضابطو', 'قدرتي دشمن', 'فائديمند جيت'],
    ),
  ];

  static List<AgriTerm> forText(String text, AppLanguage language) {
    if (!language.isSindhi) return const [];
    final normalized = text.toLowerCase();
    final matches = all.where((term) {
      return term.keywords.any((keyword) => normalized.contains(keyword));
    }).toList();
    final seen = <String>{};
    return [
      for (final term in matches)
        if (seen.add(term.sindhi)) term,
    ].take(5).toList();
  }
}
