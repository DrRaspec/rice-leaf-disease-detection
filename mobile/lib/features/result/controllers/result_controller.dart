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
    info = DiseaseInfoCatalog.byClass(result.predictedClass);
    image = args['image'] as File;
  }

  void analyseAnother() => Get.back();
}
