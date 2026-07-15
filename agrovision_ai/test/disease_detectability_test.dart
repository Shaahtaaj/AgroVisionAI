import 'package:agrovision_ai/data/disease_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mango catalog detectability follows deployed model labels', () async {
    final catalog = await DiseaseRepository.instance.getDiseaseCatalogByCrop(
      'Mango',
    );
    final byLabel = {for (final entry in catalog) entry.disease.label: entry};

    expect(byLabel['Anthracnose']?.isAiDetectable, isTrue);
    expect(byLabel['Mango Scab']?.isAiDetectable, isFalse);
    expect(byLabel['Alternaria Leaf Spot']?.isAiDetectable, isFalse);
  });
}
