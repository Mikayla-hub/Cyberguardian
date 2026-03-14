import 'dart:math';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';
import 'package:uuid/uuid.dart';

class MockScanRepository implements ScanRepository {
  final _random = Random();
  final _uuid = const Uuid();
  final List<PhishingAnalysis> _history = [];

  @override
  ResultFuture<PhishingAnalysis> analyzeEmail(String emailContent) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final lowerContent = emailContent.toLowerCase();
    final isPhishy = lowerContent.contains('urgent') ||
        lowerContent.contains('verify') ||
        lowerContent.contains('click here') ||
        lowerContent.contains('suspended') ||
        lowerContent.contains('password') ||
        lowerContent.contains('account') ||
        lowerContent.contains('winner') ||
        lowerContent.contains('congratulations');

    final isSuspicious = lowerContent.contains('offer') ||
        lowerContent.contains('free') ||
        lowerContent.contains('limited time') ||
        lowerContent.contains('act now');

    final classification = isPhishy
        ? ThreatClassification.phishing
        : isSuspicious
            ? ThreatClassification.suspicious
            : ThreatClassification.safe;

    final confidence = isPhishy
        ? 0.85 + _random.nextDouble() * 0.14
        : isSuspicious
            ? 0.55 + _random.nextDouble() * 0.25
            : 0.05 + _random.nextDouble() * 0.2;

    final suspiciousElements = <SuspiciousElement>[];
    if (lowerContent.contains('urgent') || lowerContent.contains('immediately')) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Urgency language detected',
        reason: 'Phishing emails often create false urgency to pressure victims into acting quickly.',
        severity: 0.85,
      ));
    }
    if (lowerContent.contains('click here') || lowerContent.contains('click below')) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Generic "click here" link',
        reason: 'Legitimate organizations typically use descriptive link text instead of generic calls to action.',
        severity: 0.75,
      ));
    }
    if (lowerContent.contains('verify') || lowerContent.contains('confirm your')) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Credential harvesting attempt',
        reason: 'Requests to verify or confirm personal information are a common phishing tactic.',
        severity: 0.9,
      ));
    }
    if (lowerContent.contains('suspended') || lowerContent.contains('locked')) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Account threat language',
        reason: 'Threatening account suspension is used to create panic and bypass critical thinking.',
        severity: 0.88,
      ));
    }
    if (lowerContent.contains('winner') || lowerContent.contains('congratulations')) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Prize/reward scam language',
        reason: 'Unsolicited prize notifications are almost always scams.',
        severity: 0.92,
      ));
    }

    final explanation = classification == ThreatClassification.phishing
        ? 'This email contains ${suspiciousElements.length} phishing indicator(s). '
          'The combination of urgency language, suspicious requests, and social engineering tactics '
          'strongly suggests this is a phishing attempt. Do not click any links or provide personal information.'
        : classification == ThreatClassification.suspicious
            ? 'This email contains some elements that could indicate a phishing attempt, but confidence is moderate. '
              'Exercise caution and verify the sender through an independent channel before taking any action.'
            : 'This email does not exhibit common phishing characteristics. '
              'However, always remain vigilant and verify unexpected requests through official channels.';

    final analysis = PhishingAnalysis(
      id: _uuid.v4(),
      classification: classification,
      confidenceScore: confidence,
      suspiciousElements: suspiciousElements,
      explanation: explanation,
      inputType: InputType.email,
      inputContent: emailContent.substring(0, emailContent.length.clamp(0, 100)),
      analyzedAt: DateTime.now(),
    );

    _history.insert(0, analysis);
    return Right(analysis);
  }

  @override
  ResultFuture<PhishingAnalysis> analyzeUrl(String url) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final lowerUrl = url.toLowerCase();
    final isPhishy = lowerUrl.contains('login') && !lowerUrl.contains('google.com') && !lowerUrl.contains('apple.com') ||
        lowerUrl.contains('paypa1') ||
        lowerUrl.contains('amaz0n') ||
        lowerUrl.contains('verify-account') ||
        lowerUrl.contains('.xyz') ||
        lowerUrl.contains('.tk') ||
        RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(url);

    final classification = isPhishy
        ? ThreatClassification.phishing
        : ThreatClassification.safe;

    final confidence = isPhishy ? 0.88 + _random.nextDouble() * 0.11 : 0.1 + _random.nextDouble() * 0.15;

    final suspiciousElements = <SuspiciousElement>[];
    if (isPhishy) {
      suspiciousElements.add(const SuspiciousElement(
        element: 'Suspicious domain pattern',
        reason: 'The URL uses patterns commonly associated with phishing sites (misspellings, unusual TLDs, or IP addresses).',
        severity: 0.9,
      ));
    }

    final analysis = PhishingAnalysis(
      id: _uuid.v4(),
      classification: classification,
      confidenceScore: confidence,
      suspiciousElements: suspiciousElements,
      explanation: isPhishy
          ? 'This URL shows signs of being a phishing website. The domain pattern is suspicious and may be impersonating a legitimate service.'
          : 'This URL does not exhibit obvious phishing characteristics. Always verify the domain matches the official website.',
      inputType: InputType.url,
      inputContent: url,
      analyzedAt: DateTime.now(),
    );

    _history.insert(0, analysis);
    return Right(analysis);
  }

  @override
  ResultFuture<PhishingAnalysis> analyzeScreenshot(Uint8List imageData) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    final analysis = PhishingAnalysis(
      id: _uuid.v4(),
      classification: ThreatClassification.suspicious,
      confidenceScore: 0.65,
      suspiciousElements: const [
        SuspiciousElement(
          element: 'Potential brand impersonation',
          reason: 'The screenshot appears to contain elements that mimic a well-known brand, which is a common phishing tactic.',
          severity: 0.7,
        ),
        SuspiciousElement(
          element: 'Login form detected',
          reason: 'A credential input form was detected. Verify you are on the official website before entering any information.',
          severity: 0.65,
        ),
      ],
      explanation: 'The screenshot analysis detected potential brand impersonation elements and a login form. '
          'This could be a phishing page designed to steal credentials. Verify the URL in the address bar before proceeding.',
      inputType: InputType.screenshot,
      inputContent: '[screenshot: ${imageData.length} bytes]',
      analyzedAt: DateTime.now(),
    );

    _history.insert(0, analysis);
    return Right(analysis);
  }

  @override
  ResultFuture<List<PhishingAnalysis>> getScanHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_history);
  }
}
