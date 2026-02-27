import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../app/core/core_i18n.dart';
import '../../../app/core/core_network.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/prediction_response.dart';
import '../widgets/media_picker_sheet.dart';

class HomeController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final _cameraPicker = ImagePicker();

  // ── Selected image ──────────────────────────────────────────────
  final Rx<File?> selectedImage = Rx(null);
  final Rx<AssetEntity?> selectedAsset = Rx(null);

  // ── Predict state ───────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;

  // ── Media picker state ──────────────────────────────────────────
  final RxList<AssetPathEntity> albums = <AssetPathEntity>[].obs;
  final Rx<AssetPathEntity?> currentAlbum = Rx(null);
  final RxList<AssetEntity> assets = <AssetEntity>[].obs;
  final RxBool isLoadingAssets = false.obs;
  final RxBool hasPermission = false.obs;

  static const int _pageSize = 60;
  int _page = 0;
  bool _hasMore = true;

  // ── Open Telegram-style picker ──────────────────────────────────
  Future<void> openMediaPicker() async {
    final permitted = await _requestPermission();
    if (!permitted) return;
    await _loadAlbums();
    Get.bottomSheet(
      const MediaPickerSheet(),
      isScrollControlled: true,
      ignoreSafeArea: false,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Open camera (native) ────────────────────────────────────────
  Future<void> openCamera() async {
    try {
      Get.back();
      final xfile = await _cameraPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (xfile != null) {
        selectedAsset.value = null;
        selectedImage.value = await _optimizeForUpload(File(xfile.path));
        errorMsg.value = '';
      }
    } catch (e) {
      errorMsg.value = 'Camera error: $e';
    }
  }

  // ── Confirm asset selected from grid ────────────────────────────
  Future<void> confirmAsset(AssetEntity asset) async {
    Get.back();
    selectedAsset.value = asset;
    final file = await asset.file;
    if (file != null) {
      selectedImage.value = await _optimizeForUpload(file);
      errorMsg.value = '';
    }
  }

  // ── Load albums ─────────────────────────────────────────────────
  Future<void> _loadAlbums() async {
    final list = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    albums.assignAll(list);
    if (list.isNotEmpty) await selectAlbum(list.first);
  }

  Future<void> selectAlbum(AssetPathEntity album) async {
    currentAlbum.value = album;
    assets.clear();
    _page = 0;
    _hasMore = true;
    await loadMoreAssets();
  }

  Future<void> loadMoreAssets() async {
    if (!_hasMore || isLoadingAssets.value) return;
    final album = currentAlbum.value;
    if (album == null) return;
    isLoadingAssets.value = true;
    final list = await album.getAssetListPaged(page: _page, size: _pageSize);
    if (list.length < _pageSize) _hasMore = false;
    assets.addAll(list);
    _page++;
    isLoadingAssets.value = false;
  }

  // ── Permission ──────────────────────────────────────────────────
  Future<bool> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth || result == PermissionState.limited) {
      hasPermission.value = true;
      return true;
    }
    hasPermission.value = false;
    Get.snackbar(
      AppText.t(TrKey.permissionDenied),
      AppText.t(TrKey.allowPhotoAccess),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode ? const Color(0xFF1F3A2D) : const Color(0xFFFFFFFF),
      colorText: Get.isDarkMode ? Colors.white : const Color(0xFF173125),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      mainButton: TextButton(
        onPressed: PhotoManager.openSetting,
        child: Text(
          AppText.t(TrKey.openSettings),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Get.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF16A34A),
          ),
        ),
      ),
    );
    return false;
  }

  Future<void> analyse() async {
    final img = selectedImage.value;
    if (img == null) {
      errorMsg.value = AppText.t(TrKey.pickImageFirst);
      return;
    }

    isLoading.value = true;
    errorMsg.value = '';

    try {
      final uploadFile = await _optimizeForUpload(img);
      final response = await _api.predictDisease(uploadFile.path);
      final result = PredictionResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      Get.toNamed(
        AppRoutes.result,
        arguments: {'result': result, 'image': img},
      );
    } on DioException catch (e) {
      final payload = e.response?.data;
      if (payload is Map && payload['detail'] is String) {
        errorMsg.value = payload['detail'] as String;
      } else {
        errorMsg.value = AppText.t(TrKey.requestFailed);
      }
    } on Exception catch (e) {
      errorMsg.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void clearImage() {
    selectedImage.value = null;
    selectedAsset.value = null;
    errorMsg.value = '';
  }

  Future<File> _optimizeForUpload(File source) async {
    final originalBytes = await source.length();
    final useAggressive = originalBytes > 2 * 1024 * 1024;
    final minSide = useAggressive ? 960 : 1280;
    final quality = useAggressive ? 70 : 82;

    final targetPath =
        '${Directory.systemTemp.path}/rice_upload_${DateTime.now().microsecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: quality,
      minWidth: minSide,
      minHeight: minSide,
      keepExif: false,
    );

    if (result == null) return source;
    final optimized = File(result.path);
    final optimizedBytes = await optimized.length();
    if (optimizedBytes >= originalBytes) {
      return source;
    }
    return optimized;
  }
}
