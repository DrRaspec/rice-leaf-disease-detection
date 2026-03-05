import 'dart:io';
import 'package:get/get.dart';
import '../../../data/models/prediction_response.dart';
import 'disease_info_catalog.dart';

class ResultController extends GetxController {
  late final PredictionResult result;
  late final DiseaseInfo info;
  late final File image;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    result = args['result'] as PredictionResult;
    info = _resolveDiseaseInfo(result);
    image = args['image'] as File;
  }

  DiseaseInfo _resolveDiseaseInfo(PredictionResult prediction) {
    final apiInfo = prediction.diseaseInfo;
    if (apiInfo != null && apiInfo.label.isNotEmpty) {
      return DiseaseInfo(
        key: apiInfo.key.isEmpty ? prediction.predictedClass : apiInfo.key,
        label: apiInfo.label,
        icon: apiInfo.icon,
        severity: apiInfo.severity,
        description: apiInfo.description,
        treatment: apiInfo.treatment,
      );
    }
    return DiseaseInfoCatalog.byClass(prediction.predictedClass);
  }

  void analyseAnother() => Get.back();
}
