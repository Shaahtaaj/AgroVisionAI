import 'app_language.dart';

class CropNames {
  const CropNames._();

  static const Map<String, String> _sindhi = {
    'Mango': 'انب',
    'Wheat': 'ڪڻڪ',
    'Cotton': 'ڪپھ',
    'Rice': 'چانور',
    'Tomato': 'ٽماٽو',
  };

  static String localized(String crop, AppLanguage language) {
    if (!language.isSindhi) return crop;
    return _sindhi[crop] ?? crop;
  }
}
