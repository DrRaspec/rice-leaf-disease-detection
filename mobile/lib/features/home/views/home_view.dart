import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/app_settings_service.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroCard(),
                const SizedBox(height: 20),
                _UploadCard(),
                const SizedBox(height: 20),
                _DiseasesSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) => SliverAppBar(
        expandedHeight: 0,
        floating: true,
        snap: true,
        backgroundColor: AppTheme.background.withValues(alpha: 0.95),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary700, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.eco_rounded,
                size: 20,
                color: Get.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  const TextSpan(text: 'Rice'),
                  TextSpan(
                    text: 'Guard',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                  TextSpan(
                    text: ' AI',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showDisplaySettings(context),
            icon: Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
            tooltip: 'Display Settings',
          ),
        ],
      );

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _DisplaySettingsSheet(),
    );
  }
}

class _DisplaySettingsSheet extends StatelessWidget {
  const _DisplaySettingsSheet();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();

    Widget sectionTitle(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(() {
          final selectedMode = settings.themeMode.value;
          final selectedScale = settings.fontScale.value;
          final selectedFamily = settings.fontFamily.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Display Settings',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              sectionTitle('Theme'),
              Wrap(
                spacing: 8,
                children: [
                  _ChoiceChip(
                    label: 'Dark',
                    selected: selectedMode == ThemeMode.dark,
                    onTap: () => settings.setThemeMode(ThemeMode.dark),
                  ),
                  _ChoiceChip(
                    label: 'Light',
                    selected: selectedMode == ThemeMode.light,
                    onTap: () => settings.setThemeMode(ThemeMode.light),
                  ),
                  _ChoiceChip(
                    label: 'System',
                    selected: selectedMode == ThemeMode.system,
                    onTap: () => settings.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              sectionTitle('Font Size'),
              Wrap(
                spacing: 8,
                children: AppSettingsService.fontScales.map((scale) {
                  return _ChoiceChip(
                    label: '${(scale * 100).round()}%',
                    selected: selectedScale == scale,
                    onTap: () => settings.setFontScale(scale),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              sectionTitle('Font Family'),
              Wrap(
                spacing: 8,
                children: AppSettingsService.fontFamilies.map((family) {
                  return _ChoiceChip(
                    label: family,
                    selected: selectedFamily == family,
                    onTap: () => settings.setFontFamily(family),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      side: BorderSide(
        color: selected
            ? AppTheme.primary
            : AppTheme.cardBorder.withValues(alpha: 0.8),
      ),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primary : AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppTheme.background,
      selectedColor: AppTheme.primary.withValues(alpha: 0.18),
      showCheckmark: false,
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF143d26), Color(0xFF0d2e1e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '🌾 AI-Powered Detection',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Protect Your\nRice Harvest',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Instant leaf diagnosis with deep learning.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('🌿', style: TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}

// ── Upload Card ───────────────────────────────────────────────────────────────
class _UploadCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Diagnose Your Leaf',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload a clear photo of the rice leaf',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Image preview / upload zone
          Obx(() {
            final img = controller.selectedImage.value;
            return GestureDetector(
              onTap: controller.openMediaPicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF0f2318),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: img != null
                        ? AppTheme.primary.withValues(alpha: 0.5)
                        : AppTheme.primary700.withValues(alpha: 0.3),
                    width: 2,
                    // ignore: deprecated_member_use
                    style: BorderStyle.solid,
                  ),
                ),
                child: img == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 44,
                            color: AppTheme.primary700,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to upload image',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(img, fit: BoxFit.cover),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black54],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: controller.clearImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Error
          Obx(
            () => controller.errorMsg.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '⚠️  ${controller.errorMsg.value}',
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Analyse button
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.analyse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary700.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.biotech_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Analyse Leaf',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Diseases Section ──────────────────────────────────────────────────────────
class _DiseasesSection extends StatelessWidget {
  static const _diseases = [
    ('✅', 'Healthy', 'none', 'No disease detected.'),
    (
      '🦠',
      'Bacterial Leaf Blight',
      'high',
      'Yellowing and drying of leaf margins.',
    ),
    ('💥', 'Leaf Blast', 'high', 'Diamond-shaped gray lesions.'),
    ('🟤', 'Brown Spot', 'medium', 'Oval brown spots with yellow halos.'),
    ('🔥', 'Leaf Scald', 'medium', 'Scalded brown lesions from tip.'),
    ('🟫', 'Narrow Brown Spot', 'low', 'Narrow linear spots on blade.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detectable Diseases',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...(_diseases.map(
          (d) =>
              _DiseaseRow(icon: d.$1, label: d.$2, severity: d.$3, desc: d.$4),
        )),
      ],
    );
  }
}

class _DiseaseRow extends StatelessWidget {
  final String icon, label, severity, desc;
  const _DiseaseRow({
    required this.icon,
    required this.label,
    required this.severity,
    required this.desc,
  });

  Color get _badge => switch (severity) {
        'high' => AppTheme.danger,
        'medium' => AppTheme.warning,
        'low' => AppTheme.earth,
        _ => AppTheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _badge.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _badge.withValues(alpha: 0.3)),
            ),
            child: Text(
              severity == 'none' ? 'safe' : severity,
              style: TextStyle(
                color: _badge,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
