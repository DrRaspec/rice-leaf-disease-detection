import 'dart:io';
import 'package:get/get.dart';
import '../../../data/models/prediction_model.dart';

class ResultController extends GetxController {
  late final PredictionResult result;
  late final File image;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    result = args['result'] as PredictionResult;
    image = args['image'] as File;
  }

  void analyseAnother() => Get.back();
}
