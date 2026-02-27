import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/core_i18n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/prediction_response.dart';
import '../controllers/disease_info_catalog.dart';
import '../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final info = controller.info;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(result, info),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MainResultCard(result: result, info: info),
                const SizedBox(height: 16),
                _TreatmentCard(info: info),
                const SizedBox(height: 16),
                _TopPredictionsCard(result: result),
                const SizedBox(height: 24),
                _AnalyseAnotherButton(onTap: controller.analyseAnother),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildHeader(PredictionResult result, DiseaseInfo info) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppTheme.background,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(controller.image, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.background.withValues(alpha: 0.7),
                    AppTheme.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.75, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Result Card ──────────────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _severityColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _severityColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _severityColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(info.icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
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

          // Confidence bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppText.t(TrKey.confidence),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              Text(
                '${(conf * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _severityColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: conf),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation(_severityColor),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            info.description,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          if (lowConfidence) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
              ),
              child: Text(
                AppText.t(TrKey.lowConfidence).replaceFirst(
                  '{classes}',
                  _possibleClassesLabel(result),
                ),
                style: TextStyle(
                  color: AppTheme.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _possibleClassesLabel(PredictionResult prediction) {
    if (prediction.possibleClasses.isEmpty) return AppText.t(TrKey.unknownClass);
    return prediction.possibleClasses
        .take(2)
        .map((item) => item.replaceAll('_', ' '))
        .join(' / ');
  }
}

// ── Treatment Card ────────────────────────────────────────────────────────────
class _TreatmentCard extends StatelessWidget {
  final DiseaseInfo info;
  const _TreatmentCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💊 ${AppText.t(TrKey.whatToDoNow)}',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            info.treatment,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Predictions Card ──────────────────────────────────────────────────────
class _TopPredictionsCard extends StatelessWidget {
  final PredictionResult result;
  const _TopPredictionsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.t(TrKey.topPredictions),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          ...result.topPredictions.asMap().entries.map((e) {
            final idx = e.key;
            final pred = e.value;
            final pct = pred.confidence * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pred.className.replaceAll('_', ' '),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pred.confidence),
                        duration: Duration(milliseconds: 600 + idx * 120),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(
                            AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Analyse Another Button ────────────────────────────────────────────────────
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
        foregroundColor: AppTheme.primary,
        side: BorderSide(color: AppTheme.primary700),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
}

// ── Severity Badge ────────────────────────────────────────────────────────────
class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;
  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = AppText.severityLabel(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
