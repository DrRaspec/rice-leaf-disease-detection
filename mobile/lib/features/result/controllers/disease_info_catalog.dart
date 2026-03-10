import '../../../app/core/core_i18n.dart';

class DiseaseInfo {
  final String key;
  final String label;
  final String scientificName;
  final String icon;
  final String severity;
  final String severityLabel;
  final String description;
  final String symptoms;
  final String cause;
  final String treatment;
  final String prevention;

  const DiseaseInfo({
    required this.key,
    required this.label,
    this.scientificName = '',
    required this.icon,
    required this.severity,
    this.severityLabel = '',
    required this.description,
    this.symptoms = '',
    this.cause = '',
    required this.treatment,
    this.prevention = '',
  });
}

class DiseaseInfoCatalog {
  static const _en = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'Healthy',
      scientificName: '',
      icon: 'healthy',
      severity: 'none',
      severityLabel: 'Healthy',
      description: 'The leaf appears healthy with no visible signs of disease.',
      symptoms:
          'Normal green coloration with no spots, lesions, or discoloration.',
      cause: 'N/A – the plant is not affected by disease.',
      treatment:
          'Continue normal care: maintain consistent irrigation and balanced fertilization. Inspect weekly.',
      prevention:
          'Use certified disease-free seeds. Maintain balanced nutrition (N-P-K). Ensure proper field drainage and spacing between plants.',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'Bacterial Leaf Blight',
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      icon: 'bacterial_leaf_blight',
      severity: 'high',
      severityLabel: 'High Severity',
      description:
          'A serious bacterial disease that causes rapid wilting and yellowing of rice leaves.',
      symptoms:
          'Water-soaked streaks appear along leaf edges and veins, turning yellow to white. Leaves dry out from the tip downward. Severely infected leaves become grayish-white and wilt. Milky bacterial ooze may appear on leaf surfaces in humid conditions.',
      cause:
          'Caused by the bacterium Xanthomonas oryzae pv. oryzae. Favored by warm temperatures (25–34°C), high humidity, frequent rainfall, excessive nitrogen fertilization, and wounds from wind or insects.',
      treatment:
          'Remove and destroy heavily infected leaves immediately. Improve field drainage and reduce standing water. Avoid excessive nitrogen. Apply copper-based bactericide following local agricultural guidelines.',
      prevention:
          'Plant resistant varieties (e.g. IR64, IRBB lines). Use hot-water-treated seeds (53–54°C for 10–12 min). Maintain balanced fertilization. Ensure 25×25 cm spacing for airflow. Plow under crop residues after harvest.',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'Leaf Blast',
      scientificName: 'Magnaporthe oryzae (Pyricularia oryzae)',
      icon: 'leaf_blast',
      severity: 'high',
      severityLabel: 'High Severity',
      description:
          'A devastating fungal disease that can destroy rice crops at any growth stage.',
      symptoms:
          'Diamond-shaped (spindle) lesions with gray or white centers and dark brown to reddish-brown borders. Lesions typically 1–2 cm long. Under severe infection, lesions merge and leaves wilt entirely. Can also attack nodes and panicles.',
      cause:
          'Caused by the fungus Magnaporthe oryzae. Thrives in cool nights (20–25°C), high humidity (>90%), prolonged leaf wetness, and fields with excessive nitrogen fertilization.',
      treatment:
          'Avoid excess nitrogen fertilizer immediately. Apply a recommended fungicide (e.g. tricyclazole, isoprothiolane, or edifenphos) at the first sign of lesions. Consult local agricultural extension for approved products.',
      prevention:
          'Use resistant varieties (e.g. IR66, Riang Chay). Apply balanced NPK with low nitrogen. Ensure adequate spacing. Remove and burn crop residues. Drain field during fallow. Treat seeds with fungicide before sowing.',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'Brown Spot',
      scientificName: 'Bipolaris oryzae (Helminthosporium oryzae)',
      icon: 'brown_spot',
      severity: 'medium',
      severityLabel: 'Medium Severity',
      description:
          'A fungal disease associated with nutrient-deficient soils, producing oval brown lesions.',
      symptoms:
          'Oval to circular brown spots (0.5–1 cm), often with a gray or lighter center and a yellow halo. Appear on leaves, sheaths, and grain hulls. Spots are dark brown on lower leaf surface. Heavy infection causes premature leaf death.',
      cause:
          'Caused by the fungus Bipolaris oryzae. Favored by nutrient-deficient soils (especially low potassium and silicon), drought stress, temperatures of 25–30°C, and high relative humidity.',
      treatment:
          'Improve balanced nutrition, especially potassium and silicon. Monitor spread and apply fungicide (mancozeb, carbendazim, or tebuconazole) if infection is progressing rapidly.',
      prevention:
          'Use certified, disease-free seed. Treat seeds with hot water (53–54°C for 10–12 min) or fungicide (carbendazim). Maintain soil fertility with balanced NPK. Avoid drought stress. Plow under crop residues.',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'Leaf Scald',
      scientificName: 'Monographella albescens (Microdochium oryzae)',
      icon: 'leaf_scald',
      severity: 'medium',
      severityLabel: 'Medium Severity',
      description:
          'A fungal disease causing scald-like, light brown lesions that start from the leaf tips.',
      symptoms:
          'Light brown to gray-green water-soaked lesions that start from the leaf tip or edge. The affected area dries out and looks scalded. Lesions often show alternating bands of light and dark brown (chevron pattern). Can infect leaves, leaf sheaths, and panicles.',
      cause:
          'Caused by the fungus Monographella albescens. Spread via infected seeds and crop debris. Favored by wet weather, high humidity, excessive nitrogen, and dense planting.',
      treatment:
          'Improve airflow between plants by adjusting spacing. Apply a suitable fungicide (mancozeb or thiophanate-methyl) if symptoms are progressing. Avoid excess nitrogen.',
      prevention:
          'Use disease-free seeds. Treat seeds with thiophanate-methyl or carbendazim. Avoid excessive nitrogen. Ensure adequate plant spacing. Remove and destroy crop residues after harvest. Maintain soil silicon levels.',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'Narrow Brown Spot',
      scientificName: 'Sphaerulina oryzina (Cercospora janseana)',
      icon: 'narrow_brown_spot',
      severity: 'low',
      severityLabel: 'Low Severity',
      description:
          'A minor fungal disease producing narrow, linear brown lesions on leaves.',
      symptoms:
          'Short, narrow linear lesions (2–10 mm long, about 1 mm wide) on the leaf blade, running parallel to the veins. Dark brown center with lighter margins. May also appear on leaf sheaths. In severe cases, can cause premature grain ripening.',
      cause:
          'Caused by the fungus Sphaerulina oryzina (syn. Cercospora janseana). Typically appears late in the growing season during booting to heading. Favored by temperatures of 25–28°C and potassium-deficient soils.',
      treatment:
          'Monitor the crop for 3–5 days. Spray fungicide (propiconazole or carbendazim) only if disease is spreading rapidly. Ensure adequate potassium nutrition.',
      prevention:
          'Plant tolerant varieties. Maintain balanced fertilization with adequate potassium. Remove weeds that can harbor the pathogen. Plow under crop residues after harvest.',
    ),
  };

  static const _km = {
    'healthy': DiseaseInfo(
      key: 'healthy',
      label: 'សុខភាពល្អ',
      scientificName: '',
      icon: 'healthy',
      severity: 'none',
      severityLabel: 'គ្មានជំងឺ',
      description: 'ស្លឹកមានសុខភាពល្អ គ្មានសញ្ញាជំងឺឃើញទេ។',
      symptoms: 'ស្លឹកមានពណ៌បៃតងធម្មតា គ្មានចំណុច ដំបៅ ឬការប្រែពណ៌ណាមួយឡើយ។',
      cause: 'មិនពាក់ព័ន្ធ – រុក្ខជាតិមិនមានជំងឺទេ។',
      treatment:
          'បន្តថែទាំធម្មតា៖ រក្សាស្រោចទឹកឱ្យសមស្រប និងដាក់ជីឱ្យមានតុល្យភាព។ ពិនិត្យស្រែជារៀងរាល់សប្តាហ៍។',
      prevention:
          'ប្រើគ្រាប់ពូជដែលគ្មានជំងឺ។ រក្សាជីជាតិឱ្យមានតុល្យភាព (អាសូត-ផូស្វ័រ-ប៉ូតាស្យូម)។ ធានាការបង្ហូរទឹក និងគម្លាតដាំសមស្រប។',
    ),
    'bacterial_leaf_blight': DiseaseInfo(
      key: 'bacterial_leaf_blight',
      label: 'ជំងឺរលាកស្លឹកដោយបាក់តេរី',
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      icon: 'bacterial_leaf_blight',
      severity: 'high',
      severityLabel: 'ធ្ងន់ធ្ងរ',
      description:
          'ជំងឺបាក់តេរីធ្ងន់ធ្ងរដែលបង្កឱ្យស្លឹកស្រូវស្វិត និងលឿងយ៉ាងឆាប់រហ័ស។',
      symptoms:
          'ស្នាមជោកទឹកឃើញលើគែមស្លឹក និងសរសៃស្លឹក ផ្លាស់ប្ដូរពណ៌ពីលឿងទៅស។ ស្លឹកស្ងួតពីចុងចុះក្រោម។ ស្លឹកដែលឆ្លងខ្លាំងប្រែពណ៌ប្រផេះស ហើយស្វិត។ ក្នុងស្ថានភាពសើមអាចមើលឃើញទឹករំអិលរបស់បាក់តេរីលើផ្ទៃស្លឹក។',
      cause:
          'បង្កដោយបាក់តេរី Xanthomonas oryzae pv. oryzae។ កើតមានច្រើនក្នុងសីតុណ្ហភាព ២៥–៣៤°C ភាពសើមខ្ពស់ ភ្លៀងញឹកញាប់ ការដាក់ជីអាសូតច្រើនលើស និងរបួសពីខ្យល់ឬសត្វល្អិត។',
      treatment:
          'ដកស្លឹកដែលឆ្លងខ្លាំង និងបំផ្លាញចោល។ កែលម្អការបង្ហូរទឹកក្នុងស្រែ និងកាត់បន្ថយទឹកស្ថិតនៅ។ កុំដាក់ជីអាសូតច្រើនលើស។ បាញ់ថ្នាំប្រភេទស្ពាន់ (copper-based) តាមការណែនាំកសិកម្មមូលដ្ឋាន។',
      prevention:
          'ដាំពូជធន់នឹងជំងឺ (ឧ. IR64)។ ត្រាំគ្រាប់ពូជក្នុងទឹកក្តៅ (៥៣–៥៤°C រយៈពេល ១០–១២ នាទី)។ រក្សាជីជាតិសមតុល្យ។ ដាំគម្លាត ២៥×២៥ សម ដើម្បីឱ្យខ្យល់ចេញចូល។ ភ្ជួររាស់កាកសំណល់ដំណាំបន្ទាប់ពីប្រមូលផល។',
    ),
    'leaf_blast': DiseaseInfo(
      key: 'leaf_blast',
      label: 'ជំងឺក្រុង',
      scientificName: 'Magnaporthe oryzae (Pyricularia oryzae)',
      icon: 'leaf_blast',
      severity: 'high',
      severityLabel: 'ធ្ងន់ធ្ងរ',
      description:
          'ជំងឺផ្សិតមានគ្រោះថ្នាក់ខ្លាំងដែលអាចបំផ្លាញដំណាំស្រូវគ្រប់ដំណាក់កាលនៃការលូតលាស់។',
      symptoms:
          'ស្នាមរាងពេជ្រ (រាងពងក្រពើចុងស្រួច) មានកណ្ដាលពណ៌ប្រផេះឬស និងគែមពណ៌ត្នោតងងឹតដល់ក្រហមត្នោត។ ដំបៅវែងប្រហែល ១–២ សម។ នៅពេលឆ្លងធ្ងន់ ស្នាមបញ្ចូលគ្នា ហើយស្លឹកស្វិតទាំងមូល។ អាចវាយប្រហារថ្នាំង និងទងផ្កាផងដែរ។',
      cause:
          'បង្កដោយផ្សិត Magnaporthe oryzae។ កើតច្រើនក្នុងពេលយប់ត្រជាក់ (២០–២៥°C) ភាពសើម >៩០% ស្លឹកជោកទឹកយូរ និងដាក់ជីអាសូតច្រើនលើស។',
      treatment:
          'ជៀសវាងជីអាសូតលើសភ្លាមៗ។ បាញ់ថ្នាំកម្ចាត់ផ្សិត (ឧ. tricyclazole, isoprothiolane ឬ edifenphos) ភ្លាមពេលឃើញស្នាម។ ពិគ្រោះជាមួយអ្នកជំនាញកសិកម្មមូលដ្ឋានសម្រាប់ផលិតផលដែលអនុញ្ញាត។',
      prevention:
          'ដាំពូជធន់នឹងជំងឺ (ឧ. IR66, Riang Chay)។ ដាក់ជី NPK សមតុល្យ អាសូតទាប។ ធានាគម្លាតដាំគ្រប់គ្រាន់។ ដកចេញ និងដុតកាកសំណល់ដំណាំ។ បន្សុកស្រែពេលនៅទំនេរ។ ត្រាំគ្រាប់ពូជជាមួយថ្នាំផ្សិតមុនពេលសាប។',
    ),
    'brown_spot': DiseaseInfo(
      key: 'brown_spot',
      label: 'ជំងឺអុចត្នោត',
      scientificName: 'Bipolaris oryzae (Helminthosporium oryzae)',
      icon: 'brown_spot',
      severity: 'medium',
      severityLabel: 'មធ្យម',
      description:
          'ជំងឺផ្សិតដែលបង្កឡើងក្នុងដីខ្វះជីជាតិ ធ្វើឱ្យមានចំណុចអូវ៉ាល់ពណ៌ត្នោតលើស្លឹក។',
      symptoms:
          'ចំណុចអូវ៉ាល់ដល់រាងមូល ពណ៌ត្នោត (០.៥–១ សម) ជាមួយកណ្ដាលពណ៌ប្រផេះស្រាល និងរង្វង់លឿង។ ឃើញលើស្លឹក សំបក និងគ្រាប់ស្រូវ។ ចំណុចមានពណ៌ត្នោតចាស់នៅផ្ទៃក្រោមស្លឹក។ ការឆ្លងខ្លាំងធ្វើឱ្យស្លឹកស្ងួតមុនពេល។',
      cause:
          'បង្កដោយផ្សិត Bipolaris oryzae។ កើតច្រើនក្នុងដីខ្វះជីជាតិ (ជាពិសេសប៉ូតាស្យូម និងស៊ីលីកូន) ភាពស្ងួត សីតុណ្ហភាព ២៥–៣០°C និងសំណើមខ្ពស់។',
      treatment:
          'កែលម្អជីជាតិដោយបន្ថែមប៉ូតាស្យូម និងស៊ីលីកូន។ តាមដានការរាលដាល ហើយបាញ់ថ្នាំផ្សិត (mancozeb, carbendazim ឬ tebuconazole) បើឆ្លងកាន់តែខ្លាំង។',
      prevention:
          'ប្រើគ្រាប់ពូជគ្មានជំងឺដែលបានផ្ទៀងផ្ទាត់។ ត្រាំគ្រាប់ពូជក្នុងទឹកក្តៅ (៥៣–៥៤°C រយៈពេល ១០–១២ នាទី) ឬថ្នាំផ្សិត carbendazim។ រក្សាជីជាតិដីសមតុល្យ។ ចៀសវាងភាពស្ងួត។ ភ្ជួររាស់កាកដំណាំបន្ទាប់ប្រមូលផល។',
    ),
    'leaf_scald': DiseaseInfo(
      key: 'leaf_scald',
      label: 'ជំងឺដំបៅស្លឹក',
      scientificName: 'Monographella albescens (Microdochium oryzae)',
      icon: 'leaf_scald',
      severity: 'medium',
      severityLabel: 'មធ្យម',
      description:
          'ជំងឺផ្សិតដែលបង្កឱ្យមានដំបៅដូចត្រូវទឹកក្តៅរលាក ចាប់ផ្តើមពីចុងស្លឹក។',
      symptoms:
          'ដំបៅពណ៌ត្នោតស្រាលដល់បៃតងប្រផេះ ជោកទឹក ចាប់ផ្ដើមពីចុង ឬគែមស្លឹក។ ផ្នែកដែលរងប៉ះពាល់ស្ងួត ហើយមើលទៅដូចត្រូវទឹកក្តៅរលាក។ ដំបៅបង្ហាញលំនាំកៅអក (chevron pattern) ពណ៌ត្នោតស្រាល និងចាស់។ អាចឆ្លងស្លឹក សំបកស្លឹក និងទងផ្កា។',
      cause:
          'បង្កដោយផ្សិត Monographella albescens។ ឆ្លងតាមគ្រាប់ពូជ និងកាកដំណាំ។ កើតច្រើនក្នុងអាកាសធាតុសើម ភាពសើមខ្ពស់ ជីអាសូតច្រើន និងដាំក្នុងគម្លាតជិត។',
      treatment:
          'កែលម្អខ្យល់ចេញចូលរវាងដើមស្រូវដោយកែតម្រូវគម្លាតដាំ។ បាញ់ថ្នាំផ្សិត (mancozeb ឬ thiophanate-methyl) បើរោគសញ្ញាកាន់តែខ្លាំង។ ជៀសវាងជីអាសូតលើស។',
      prevention:
          'ប្រើគ្រាប់ពូជគ្មានជំងឺ។ ត្រាំគ្រាប់ពូជជាមួយ thiophanate-methyl ឬ carbendazim។ ជៀសវាងជីអាសូតលើស។ ធានាគម្លាតដាំសមស្រប។ ដកចេញ និងបំផ្លាញកាកដំណាំបន្ទាប់ប្រមូលផល។ រក្សាកម្រិតស៊ីលីកូនក្នុងដី។',
    ),
    'narrow_brown_spot': DiseaseInfo(
      key: 'narrow_brown_spot',
      label: 'ជំងឺឆ្នូតត្នោត',
      scientificName: 'Sphaerulina oryzina (Cercospora janseana)',
      icon: 'narrow_brown_spot',
      severity: 'low',
      severityLabel: 'ស្រាល',
      description:
          'ជំងឺផ្សិតស្រាលដែលបង្កឱ្យមានដំបៅលីនេអ៊ែរតូចចង្អៀតពណ៌ត្នោតលើស្លឹក។',
      symptoms:
          'ដំបៅតូចចង្អៀត រាងបន្ទាត់ (វែង ២–១០ មម ទទឹង ~១ មម) នៅលើផ្ទៃស្លឹក ស្របទៅនឹងសរសៃស្លឹក។ កណ្ដាលពណ៌ត្នោតចាស់ មានគែមពណ៌ស្រាល។ អាចឃើញនៅលើសំបកដើម។ ក្នុងករណីធ្ងន់ អាចធ្វើឱ្យគ្រាប់ស្រូវទុំមុនពេល។',
      cause:
          'បង្កដោយផ្សិត Sphaerulina oryzina (syn. Cercospora janseana)។ ជាធម្មតាលេចឡើងចុងរដូវដាំដុះ ក្នុងដំណាក់កាលចេញផ្កា។ កើតច្រើនក្នុងសីតុណ្ហភាព ២៥–២៨°C និងដីខ្វះប៉ូតាស្យូម។',
      treatment:
          'តាមដានរយៈពេល ៣–៥ ថ្ងៃ។ បាញ់ថ្នាំផ្សិត (propiconazole ឬ carbendazim) បើជំងឺរាលដាលលឿន។ ធានាជីជាតិប៉ូតាស្យូមគ្រប់គ្រាន់។',
      prevention:
          'ដាំពូជដែលទ្រាំនឹងជំងឺ។ រក្សាជីជាតិសមតុល្យជាមួយប៉ូតាស្យូមគ្រប់គ្រាន់។ កម្ចាត់ស្មៅដែលជាជម្រកផ្សិត។ ភ្ជួររាស់កាកដំណាំបន្ទាប់ប្រមូលផល។',
    ),
  };

  static DiseaseInfo byClass(String key) {
    final db = AppText.isKhmer ? _km : _en;
    return db[key] ??
        DiseaseInfo(
          key: key,
          label: key.replaceAll('_', ' '),
          icon: 'unknown',
          severity: 'unknown',
          description: '',
          treatment: '',
        );
  }
}
