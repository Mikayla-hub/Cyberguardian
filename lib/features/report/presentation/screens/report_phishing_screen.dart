import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/presentation/providers/report_provider.dart';

class ReportPhishingScreen extends ConsumerStatefulWidget {
  const ReportPhishingScreen({super.key});

  @override
  ConsumerState<ReportPhishingScreen> createState() => _ReportPhishingScreenState();
}

class _ReportPhishingScreenState extends ConsumerState<ReportPhishingScreen> {
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void dispose() {
    _contentController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final url = _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null;
    final screenshot = _selectedImage != null ? await _selectedImage!.readAsBytes() : null;

    await ref.read(reportProvider.notifier).submitReport(
          contentText: content,
          url: url,
          screenshot: screenshot,
        );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final theme = Theme.of(context);

    // Pre-classify as user types
    _contentController.addListener(() {
      if (_contentController.text.length > 10) {
        ref.read(reportProvider.notifier).preClassify(
              _contentController.text,
              url: _urlController.text.isNotEmpty ? _urlController.text : null,
            );
      }
    });

    if (reportState.status == ReportSubmissionStatus.submitted) {
      return _SubmittedView(
        report: reportState.submittedReport!,
        onDone: () {
          ref.read(reportProvider.notifier).reset();
          context.pop();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Phishing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.report_outlined, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Suspicious Activity',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Your report helps protect everyone. AI will auto-classify it.',
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
            const SizedBox(height: 24),

            // AI pre-classification chip
            if (reportState.preClassification != null) ...[
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'AI suggests: ',
                    style: theme.textTheme.bodySmall,
                  ),
                  Chip(
                    label: Text(
                      _categoryLabel(reportState.preClassification!),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Content input
            Text('Describe the suspicious activity', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste the suspicious email, describe the incident...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // URL input
            Text('Suspicious URL (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),

            // Screenshot
            Text('Screenshot (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_selectedImage != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.image, color: AppColors.primary),
                  title: Text(_selectedImage!.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Attach Screenshot'),
              ),
            const SizedBox(height: 32),

            // Error
            if (reportState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reportState.errorMessage!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: reportState.status == ReportSubmissionStatus.submitting ? null : _submit,
                icon: reportState.status == ReportSubmissionStatus.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  reportState.status == ReportSubmissionStatus.submitting
                      ? 'Submitting...'
                      : 'Submit Report',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(ReportCategory category) {
    switch (category) {
      case ReportCategory.emailPhishing:
        return 'Email Phishing';
      case ReportCategory.websiteSpoofing:
        return 'Website Spoofing';
      case ReportCategory.smsPhishing:
        return 'SMS Phishing';
      case ReportCategory.socialEngineering:
        return 'Social Engineering';
    }
  }
}

class _SubmittedView extends StatelessWidget {
  final PhishingReport report;
  final VoidCallback onDone;

  const _SubmittedView({required this.report, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.riskSafe.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      size: 48, color: AppColors.riskSafe),
                ),
                const SizedBox(height: 24),
                Text(
                  'Report Submitted',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your report has been securely submitted and will be reviewed.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // Case ID card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Case ID', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          report.caseId,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(report.categoryLabel),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                '${(report.aiConfidence * 100).toStringAsFixed(0)}% confidence',
                              ),
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
