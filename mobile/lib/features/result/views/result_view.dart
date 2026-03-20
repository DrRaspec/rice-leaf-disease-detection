import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/core_i18n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/disease_icon_theme.dart';
import '../../../data/models/prediction_response.dart';
import '../controllers/disease_info_catalog.dart';
import '../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final info = controller.info;
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          _ResultHeader(image: controller.image, result: result, info: info),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MainResultCard(result: result, info: info),
                const SizedBox(height: 18),
                _TreatmentCard(info: info),
                const SizedBox(height: 18),
                _TopPredictionsCard(result: result),
                const SizedBox(height: 28),
                _AnalyseAnotherButton(onTap: controller.analyseAnother),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final File image;
  final PredictionResult result;
  final DiseaseInfo info;

  const _ResultHeader({
    required this.image,
    required this.result,
    required this.info,
  });

  Color get _severityColor => switch (info.severity) {
        'high' => AppTheme.danger,
        'medium' => AppTheme.warning,
        'low' => AppTheme.earth,
        'none' => AppTheme.success,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: scaffoldBackground,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
        child: _GlassActionButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.52),
                    AppTheme.background.withValues(alpha: 0.88),
                    AppTheme.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.58, 0.82, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _HeaderBadge(
                            icon: DiseaseIconTheme.data(info.icon),
                            color: _severityColor,
                            label: AppText.severityLabel(info.severity),
                          ),
                          const SizedBox(width: 10),
                          _HeaderBadge(
                            icon: Icons.analytics_rounded,
                            color: AppTheme.highlight,
                            label:
                                '${(result.confidence * 100).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        info.label,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.04,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 16,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          shadows: const [
                            Shadow(
                              color: Color(0x80000000),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withValues(alpha: 0.24),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _HeaderBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MainResultCard extends StatelessWidget {
  final PredictionResult result;
  final DiseaseInfo info;

  const _MainResultCard({required this.result, required this.info});

  Color get _severityColor => switch (info.severity) {
        'high' => AppTheme.danger,
        'medium' => AppTheme.warning,
        'low' => AppTheme.earth,
        'none' => AppTheme.success,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final conf = result.confidence;
    final lowConfidence = result.isUncertain || conf < 0.45;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _severityColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _severityColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Icon(
                  DiseaseIconTheme.data(info.icon),
                  size: 30,
                  color: DiseaseIconTheme.color(info.icon),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _SeverityBadge(
                      severity: info.severity,
                      color: _severityColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.background
                  .withValues(alpha: Get.isDarkMode ? 0.45 : 0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.cardBorder.withValues(alpha: 0.75),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppText.t(TrKey.confidence),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    Text(
                      '${(conf * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _severityColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: conf),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 12,
                      backgroundColor:
                          AppTheme.cardBorder.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(_severityColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            info.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (lowConfidence) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppText.t(TrKey.lowConfidence).replaceFirst(
                        '{classes}',
                        _possibleClassesLabel(result),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _possibleClassesLabel(PredictionResult prediction) {
    if (prediction.possibleClasses.isEmpty) {
      return AppText.t(TrKey.unknownClass);
    }
    return prediction.possibleClasses
        .take(2)
        .map((item) => item.replaceAll('_', ' '))
        .join(' / ');
  }
}

class _TreatmentCard extends StatelessWidget {
  final DiseaseInfo info;

  const _TreatmentCard({required this.info});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppText.t(TrKey.whatToDoNow),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            info.treatment,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _TopPredictionsCard extends StatelessWidget {
  final PredictionResult result;

  const _TopPredictionsCard({required this.result});

  @override
  Widget build(BuildContext context) {
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
            AppText.t(TrKey.topPredictions),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...result.topPredictions.asMap().entries.map((entry) {
            final idx = entry.key;
            final pred = entry.value;
            final pct = pred.confidence * 100;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: idx == result.topPredictions.length - 1 ? 0 : 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.background
                      .withValues(alpha: Get.isDarkMode ? 0.42 : 0.76),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.cardBorder.withValues(alpha: 0.72)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pred.className.replaceAll('_', ' '),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pred.confidence),
                              duration: Duration(milliseconds: 600 + idx * 120),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => LinearProgressIndicator(
                                value: v,
                                minHeight: 8,
                                backgroundColor:
                                    AppTheme.cardBorder.withValues(alpha: 0.5),
                                valueColor:
                                    AlwaysStoppedAnimation(AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnalyseAnotherButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AnalyseAnotherButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.refresh_rounded, size: 20),
      label: Text(AppText.t(TrKey.analyzeAnotherLeaf)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary700,
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
        backgroundColor: AppTheme.card,
        minimumSize: const Size(double.infinity, 58),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;

  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = AppText.severityLabel(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
