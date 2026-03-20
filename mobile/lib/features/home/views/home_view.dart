import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/core_i18n.dart';
import '../../../app/core/core_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/disease_icon_theme.dart';
import '../../result/controllers/disease_info_catalog.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width >= 1024) {
            return const _HomeScrollBody(compact: false);
          } else if (width >= 600) {
            final isLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;
            return _HomeScrollBody(compact: !isLandscape);
          }
          return const _HomeScrollBody(compact: true);
        },
      ),
    );
  }
}

class _HomeScrollBody extends StatelessWidget {
  final bool compact;
  const _HomeScrollBody({required this.compact});

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 20.0 : 28.0;
    return CustomScrollView(
      slivers: [
        _HomeHeader(compact: compact),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 40),
          sliver: SliverToBoxAdapter(
            child: compact
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(),
                      SizedBox(height: 16),
                      _UploadCard(),
                      SizedBox(height: 16),
                      _DiseasesSection(),
                    ],
                  )
                : const _WideContent(),
          ),
        ),
      ],
    );
  }
}

class _WideContent extends StatelessWidget {
  const _WideContent();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 12,
          child: Column(
            children: [
              _HeroCard(),
              SizedBox(height: 20),
              _UploadCard(),
            ],
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 10,
          child: _DiseasesSection(),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final bool compact;
  const _HomeHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      toolbarHeight: 68,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: scaffoldBackground.withValues(alpha: 0.96),
      titleSpacing: compact ? 20 : 28,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary700,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 22,
              color: Get.isDarkMode ? const Color(0xFF17251C) : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RiceGuard AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
                Text(
                  AppText.t(TrKey.heroTag),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _HeaderAction(
            icon: Icons.tune_rounded,
            label: AppText.t(TrKey.displaySettings),
            onTap: () => _showDisplaySettings(context),
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _DisplaySettingsSheet(),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Icon(icon, color: AppTheme.textPrimary),
        ),
      ),
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
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      );
    }

    return SafeArea(
      child: Obx(() {
        final selectedMode = settings.themeMode.value;
        final selectedFontSize = settings.fontSize.value;
        final selectedZoom = settings.zoomScale.value;
        final selectedFamily = settings.selectedFontFamily;
        final visibleFontFamilies = settings.visibleFontFamilies;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppText.t(TrKey.displaySettings),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 18),
                  sectionTitle(AppText.t(TrKey.theme)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChoiceChip(
                        label: AppText.t(TrKey.dark),
                        selected: selectedMode == ThemeMode.dark,
                        onTap: () => settings.setThemeMode(ThemeMode.dark),
                      ),
                      _ChoiceChip(
                        label: AppText.t(TrKey.light),
                        selected: selectedMode == ThemeMode.light,
                        onTap: () => settings.setThemeMode(ThemeMode.light),
                      ),
                      _ChoiceChip(
                        label: AppText.t(TrKey.system),
                        selected: selectedMode == ThemeMode.system,
                        onTap: () => settings.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  sectionTitle(AppText.t(TrKey.fontSize)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppSettingsService.fontSizes.map((size) {
                      return _ChoiceChip(
                        label: size.toStringAsFixed(0),
                        selected: selectedFontSize == size,
                        onTap: () => settings.setFontSize(size),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  sectionTitle(AppText.t(TrKey.zoom)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppSettingsService.zoomScales.map((scale) {
                      return _ChoiceChip(
                        label: '${(scale * 100).round()}%',
                        selected: selectedZoom == scale,
                        onTap: () => settings.setZoomScale(scale),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  sectionTitle(AppText.t(TrKey.fontFamily)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: visibleFontFamilies.map((family) {
                      return _ChoiceChip(
                        label: family,
                        selected: selectedFamily == family,
                        onTap: () => settings.setFontFamily(family),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  sectionTitle(AppText.t(TrKey.language)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChoiceChip(
                        label: AppText.t(TrKey.khmer),
                        selected: settings.languageCode.value == 'km',
                        onTap: () => settings.setLanguageCode('km'),
                      ),
                      _ChoiceChip(
                        label: AppText.t(TrKey.english),
                        selected: settings.languageCode.value == 'en',
                        onTap: () => settings.setLanguageCode('en'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
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
    final selectedFill = AppTheme.primary.withValues(alpha: 0.18);
    final selectedPressedFill = AppTheme.primary.withValues(alpha: 0.28);
    final unselectedFill = AppTheme.background;
    final unselectedPressedFill = AppTheme.primary.withValues(alpha: 0.08);

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      color: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        final isPressed = states.contains(WidgetState.pressed);
        if (isSelected && isPressed) return selectedPressedFill;
        if (isSelected) return selectedFill;
        if (isPressed) return unselectedPressedFill;
        return unselectedFill;
      }),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: AppTheme.primary);
        }
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: AppTheme.primary.withValues(alpha: 0.55));
        }
        return BorderSide(color: AppTheme.cardBorder.withValues(alpha: 0.9));
      }),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primary700 : AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      pressElevation: 0,
      showCheckmark: false,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.t(TrKey.heroTitle),
            style: theme.displaySmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppText.t(TrKey.heroSubtitle),
            style: theme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends GetView<HomeController> {
  const _UploadCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary
                .withValues(alpha: Get.isDarkMode ? 0.06 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.t(TrKey.uploadTitle),
            style: theme.headlineSmall?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            AppText.t(TrKey.uploadSubtitle),
            style: theme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Obx(() {
            final img = controller.selectedImage.value;
            return InkWell(
              onTap: controller.openMediaPicker,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: img != null ? 220 : null,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: img == null
                        ? AppTheme.primary.withValues(alpha: 0.32)
                        : AppTheme.primary700.withValues(alpha: 0.55),
                    width: img == null ? 1.5 : 2,
                  ),
                ),
                child: img == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.cardBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppText.t(TrKey.tapToUpload),
                                  style: theme.titleMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppText.t(TrKey.cameraGallery),
                                  style: theme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(img, fit: BoxFit.cover),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.16),
                                    Colors.black.withValues(alpha: 0.54),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.36),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Text(
                                        AppText.t(TrKey.uploadTitle),
                                        style: theme.labelLarge?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _FloatingIconButton(
                                    icon: Icons.close_rounded,
                                    onTap: controller.clearImage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.muted,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_rounded,
                    color: AppTheme.highlight, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppText.t(TrKey.uploadTip),
                    style: theme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.errorMsg.value.isEmpty
                ? const SizedBox(height: 16)
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.danger),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.errorMsg.value,
                              style: theme.bodyMedium?.copyWith(
                                color: AppTheme.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.analyse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor:
                    AppTheme.primary700.withValues(alpha: 0.35),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.biotech_rounded,
                            size: 20, color: Colors.black),
                        const SizedBox(width: 10),
                        Text(
                          AppText.t(TrKey.analyze),
                          style:
                              theme.labelLarge?.copyWith(color: Colors.black),
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

class _FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _DiseasesSection extends StatelessWidget {
  const _DiseasesSection();

  static const _diseaseKeys = [
    'healthy',
    'bacterial_leaf_blight',
    'leaf_blast',
    'brown_spot',
    'leaf_scald',
    'narrow_brown_spot',
  ];

  @override
  Widget build(BuildContext context) {
    final diseases =
        _diseaseKeys.map(DiseaseInfoCatalog.byClass).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.t(TrKey.detectableDiseases),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            AppText.t(TrKey.heroSubtitle),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...diseases.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DiseaseRow(
                icon: d.icon,
                label: d.label,
                severity: d.severity,
                desc: d.description,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiseaseRow extends StatelessWidget {
  final String icon;
  final String label;
  final String severity;
  final String desc;

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            AppTheme.background.withValues(alpha: Get.isDarkMode ? 0.4 : 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: DiseaseIconTheme.color(icon).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: DiseaseIconTheme.color(icon).withValues(alpha: 0.24),
              ),
            ),
            child: Icon(
              DiseaseIconTheme.data(icon),
              size: 22,
              color: DiseaseIconTheme.color(icon),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _badge.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _badge.withValues(alpha: 0.24)),
            ),
            child: Text(
              AppText.severityLabel(severity),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _badge,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
