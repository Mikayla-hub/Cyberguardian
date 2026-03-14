import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/presentation/providers/scan_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  late TabController _tabController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;

    switch (_tabController.index) {
      case 0:
        await ref.read(scanProvider.notifier).scanEmail(content);
      case 1:
        await ref.read(scanProvider.notifier).scanUrl(content);
    }
  }

  Future<void> _handleScreenshot() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    await ref.read(scanProvider.notifier).scanScreenshot(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Scan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.email_outlined), text: 'Email'),
            Tab(icon: Icon(Icons.link), text: 'URL'),
            Tab(icon: Icon(Icons.image_outlined), text: 'Screenshot'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Email tab
                _InputTab(
                  controller: _inputController,
                  hintText: 'Paste suspicious email content here...',
                  maxLines: 8,
                ),
                // URL tab
                _InputTab(
                  controller: _inputController,
                  hintText: 'Enter suspicious URL...',
                  maxLines: 1,
                  keyboardType: TextInputType.url,
                ),
                // Screenshot tab
                _ScreenshotTab(onPickImage: _handleScreenshot),
              ],
            ),
          ),

          // Scan button
          if (_tabController.index < 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: scanState.status == ScanStatus.scanning ? null : _handleScan,
                  icon: scanState.status == ScanStatus.scanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.radar),
                  label: Text(
                    scanState.status == ScanStatus.scanning ? 'Analyzing...' : 'Scan Now',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),

          // Results
          if (scanState.status == ScanStatus.completed && scanState.result != null)
            _ScanResultCard(analysis: scanState.result!),

          if (scanState.status == ScanStatus.error)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          scanState.errorMessage ?? 'An error occurred',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InputTab extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  const _InputTab({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class _ScreenshotTab extends StatelessWidget {
  final VoidCallback onPickImage;

  const _ScreenshotTab({required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Upload a screenshot', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Take a screenshot of the suspicious content',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.upload),
            label: const Text('Choose Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanResultCard extends StatefulWidget {
  final PhishingAnalysis analysis;

  const _ScanResultCard({required this.analysis});

  @override
  State<_ScanResultCard> createState() => _ScanResultCardState();
}

class _ScanResultCardState extends State<_ScanResultCard> {
  bool _expanded = false;

  Color get _statusColor {
    switch (widget.analysis.classification) {
      case ThreatClassification.safe:
        return AppColors.riskSafe;
      case ThreatClassification.suspicious:
        return AppColors.riskMedium;
      case ThreatClassification.phishing:
        return AppColors.riskCritical;
    }
  }

  IconData get _statusIcon {
    switch (widget.analysis.classification) {
      case ThreatClassification.safe:
        return Icons.check_circle;
      case ThreatClassification.suspicious:
        return Icons.warning;
      case ThreatClassification.phishing:
        return Icons.dangerous;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        color: _statusColor.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 35,
                  lineWidth: 6,
                  percent: widget.analysis.confidenceScore,
                  center: Text(
                    '${(widget.analysis.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: _statusColor,
                  backgroundColor: _statusColor.withValues(alpha: 0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_statusIcon, color: _statusColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            widget.analysis.classificationLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.analysis.suspiciousElements.length} suspicious element(s) found',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expandable explanation
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Why?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: _statusColor,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.analysis.explanation,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (widget.analysis.suspiciousElements.isNotEmpty)
              ...widget.analysis.suspiciousElements.map(
                (el) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flag, size: 16, color: _statusColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              el.element,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              el.reason,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
