import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

class MockLearningRepository implements LearningRepository {
  final List<String> _completedLessons = [];
  int _totalXp = 150;
  final int _streakDays = 3;

  final _lessons = <Lesson>[
    const Lesson(
      id: 'lesson_001',
      title: 'Spotting Phishing Emails',
      description: 'Learn to identify the telltale signs of phishing emails, including suspicious sender addresses, urgency tactics, and malicious links.',
      category: LessonCategory.emailPhishing,
      difficulty: LessonDifficulty.beginner,
      durationMinutes: 10,
      xpReward: 50,
      contents: [
        LessonContent(
          type: 'text',
          data: 'Phishing emails are designed to trick you into revealing sensitive information. '
              'They often impersonate trusted organizations like banks, tech companies, or government agencies.\n\n'
              'Key signs of a phishing email:\n\n'
              '1. Sender address doesn\'t match the organization\n'
              '2. Generic greetings like "Dear Customer"\n'
              '3. Urgent language demanding immediate action\n'
              '4. Suspicious links that don\'t match the claimed destination\n'
              '5. Poor grammar and spelling errors\n'
              '6. Requests for personal information\n'
              '7. Unexpected attachments',
        ),
        LessonContent(
          type: 'interactive',
          data: 'Examine this email header: From: security@paypa1-support.com\n\n'
              'Notice the sender domain uses the number "1" instead of the letter "l" in "paypal". '
              'This is a common typosquatting technique used by phishers.',
        ),
        LessonContent(
          type: 'text',
          data: 'What to do when you suspect a phishing email:\n\n'
              '1. Do NOT click any links\n'
              '2. Do NOT download attachments\n'
              '3. Report it using the PhishGuard AI Report button\n'
              '4. Delete the email\n'
              '5. If you already clicked, change your passwords immediately',
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q1_001',
          question: 'Which sender address is most likely a phishing attempt?',
          options: [
            'support@apple.com',
            'noreply@google.com',
            'security@amaz0n-alerts.com',
            'billing@microsoft.com',
          ],
          correctIndex: 2,
          explanation: 'The domain "amaz0n-alerts.com" uses a zero instead of "o" and is not an official Amazon domain. This is a typosquatting technique.',
        ),
        QuizQuestion(
          id: 'q1_002',
          question: 'What should you do first if you receive a suspicious email claiming your account is locked?',
          options: [
            'Click the link to unlock your account',
            'Reply asking if it\'s real',
            'Go directly to the official website to check',
            'Forward it to your friends as a warning',
          ],
          correctIndex: 2,
          explanation: 'Always navigate to the official website directly by typing the URL yourself, never through links in suspicious emails.',
        ),
        QuizQuestion(
          id: 'q1_003',
          question: 'Which of these is a red flag in a phishing email?',
          options: [
            'The email has a company logo',
            'The email addresses you by your full name',
            'The email creates urgency and threatens account closure',
            'The email was sent during business hours',
          ],
          correctIndex: 2,
          explanation: 'Creating urgency and threatening consequences is a classic social engineering tactic to bypass your critical thinking.',
        ),
      ],
    ),
    const Lesson(
      id: 'lesson_002',
      title: 'Recognising Fake Websites',
      description: 'Master the art of identifying spoofed websites that steal your credentials and personal data.',
      category: LessonCategory.websiteSpoofing,
      difficulty: LessonDifficulty.beginner,
      durationMinutes: 12,
      xpReward: 60,
      contents: [
        LessonContent(
          type: 'text',
          data: 'Fake websites are designed to look identical to legitimate sites. '
              'They capture your login credentials and personal information.\n\n'
              'How to spot a fake website:\n\n'
              '1. Check the URL carefully for misspellings\n'
              '2. Look for HTTPS and the padlock icon\n'
              '3. Verify the domain matches the real organization\n'
              '4. Check for poor quality images or broken layouts\n'
              '5. Be wary of pop-ups asking for login information',
        ),
        LessonContent(
          type: 'interactive',
          data: 'Compare these URLs:\n\n'
              'Real: https://www.paypal.com/login\n'
              'Fake: https://www.paypa1.com/login\n'
              'Fake: https://paypal.secure-login.xyz/auth\n\n'
              'The real URL uses the exact domain. Fakes use misspellings or add extra subdomains.',
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q2_001',
          question: 'Which URL is legitimate?',
          options: [
            'https://signin.google.com',
            'https://google.signin-verify.com',
            'https://g00gle.com/signin',
            'http://google-login.net',
          ],
          correctIndex: 0,
          explanation: 'Only "signin.google.com" is a legitimate Google subdomain. The others use deceptive domain names.',
        ),
        QuizQuestion(
          id: 'q2_002',
          question: 'A website has HTTPS. Does that guarantee it\'s safe?',
          options: [
            'Yes, HTTPS means the site is verified and trustworthy',
            'No, phishing sites can also have HTTPS certificates',
            'Yes, only real companies can get HTTPS',
            'It depends on the browser you use',
          ],
          correctIndex: 1,
          explanation: 'HTTPS only means the connection is encrypted. Phishing sites can easily obtain free SSL certificates.',
        ),
      ],
    ),
    const Lesson(
      id: 'lesson_003',
      title: 'SMS Phishing (Smishing)',
      description: 'Understand how attackers use text messages to phish for information and how to protect yourself.',
      category: LessonCategory.smishing,
      difficulty: LessonDifficulty.intermediate,
      durationMinutes: 8,
      xpReward: 75,
      contents: [
        LessonContent(
          type: 'text',
          data: 'Smishing (SMS Phishing) is the use of text messages to trick victims.\n\n'
              'Common smishing tactics:\n\n'
              '1. Package delivery notifications with tracking links\n'
              '2. Bank alerts about suspicious activity\n'
              '3. Prize notifications\n'
              '4. Government impersonation (tax refunds, fines)\n'
              '5. Two-factor authentication code theft',
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q3_001',
          question: 'You receive a text: "Your package could not be delivered. Click here to reschedule: bit.ly/pkg382". What should you do?',
          options: [
            'Click the link to reschedule',
            'Check the tracking number on the official carrier website',
            'Reply STOP to unsubscribe',
            'Call the number that sent the text',
          ],
          correctIndex: 1,
          explanation: 'Always go directly to the official carrier website to check delivery status. Never click links in unexpected delivery texts.',
        ),
      ],
    ),
    const Lesson(
      id: 'lesson_004',
      title: 'Social Engineering Defence',
      description: 'Learn how attackers manipulate human psychology and how to defend against social engineering attacks.',
      category: LessonCategory.socialEngineering,
      difficulty: LessonDifficulty.advanced,
      durationMinutes: 15,
      xpReward: 100,
      badgeId: 'badge_social_eng',
      contents: [
        LessonContent(
          type: 'text',
          data: 'Social engineering exploits human psychology rather than technical vulnerabilities.\n\n'
              'Core principles attackers exploit:\n\n'
              '1. Authority - Impersonating bosses or officials\n'
              '2. Urgency - Creating time pressure\n'
              '3. Scarcity - Limited-time offers\n'
              '4. Social proof - "Everyone else is doing it"\n'
              '5. Reciprocity - Offering something first\n'
              '6. Familiarity - Pretending to know you',
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q4_001',
          question: 'Your "CEO" emails you urgently requesting a wire transfer. The email looks legitimate. What\'s the best action?',
          options: [
            'Process the transfer quickly since it\'s urgent',
            'Email back to confirm the request',
            'Call the CEO directly using a known phone number to verify',
            'Forward it to a colleague for a second opinion',
          ],
          correctIndex: 2,
          explanation: 'Always verify urgent financial requests through a separate, trusted communication channel. CEO fraud is one of the most costly phishing attacks.',
        ),
      ],
    ),
    const Lesson(
      id: 'lesson_005',
      title: 'Safe Online Behaviour',
      description: 'Build healthy security habits for everyday online activities including browsing, email, and social media.',
      category: LessonCategory.safeBehavior,
      difficulty: LessonDifficulty.beginner,
      durationMinutes: 10,
      xpReward: 50,
      contents: [
        LessonContent(
          type: 'text',
          data: 'Building safe online habits is your best defence against phishing.\n\n'
              'Essential habits:\n\n'
              '1. Use unique passwords for every account\n'
              '2. Enable two-factor authentication everywhere\n'
              '3. Keep software and apps updated\n'
              '4. Think before you click any link\n'
              '5. Verify requests through official channels\n'
              '6. Report suspicious activity immediately\n'
              '7. Use a password manager',
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q5_001',
          question: 'What is the most effective way to protect your accounts?',
          options: [
            'Use one strong password for all accounts',
            'Change your password every week',
            'Use unique passwords + two-factor authentication',
            'Only use private browsing mode',
          ],
          correctIndex: 2,
          explanation: 'Unique passwords prevent one breach from compromising all accounts. Two-factor authentication adds a second layer even if your password is stolen.',
        ),
      ],
    ),
  ];

  @override
  ResultFuture<List<Lesson>> getLessons() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_lessons);
  }

  @override
  ResultFuture<Lesson> getLessonById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lesson = _lessons.firstWhere((l) => l.id == id, orElse: () => _lessons.first);
    return Right(lesson);
  }

  @override
  ResultFuture<UserProgress> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(_buildProgress());
  }

  @override
  ResultFuture<UserProgress> completeLesson(String lessonId, int quizScore) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      _totalXp += 50 + (quizScore ~/ 10);
    }
    return Right(_buildProgress());
  }

  @override
  ResultFuture<UserProgress> awardXp(int xpAmount) async {
    _totalXp += xpAmount;
    return Right(_buildProgress());
  }

  @override
  ResultFuture<List<Lesson>> getRecommendedLessons(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(_lessons);
  }

  @override
  ResultFuture<void> cacheLessonsLocally(List<Lesson> lessons) async {
    return const Right(null);
  }

  @override
  ResultFuture<List<Lesson>> getCachedLessons() async {
    return Right(_lessons);
  }

  UserProgress _buildProgress() {
    return UserProgress(
      userId: 'usr_demo_001',
      totalXp: _totalXp,
      currentLevel: _totalXp ~/ 500 + 1,
      phishingRiskScore: (1.0 - _completedLessons.length * 0.15).clamp(0.1, 1.0),
      completedLessonIds: List.unmodifiable(_completedLessons),
      badges: _completedLessons.length >= 3
          ? [
              LearningBadge(
                id: 'badge_001',
                name: 'Quick Learner',
                description: 'Completed 3 lessons',
                iconUrl: '',
                earnedAt: DateTime.now(),
              ),
            ]
          : [],
      quizScores: {for (final id in _completedLessons) id: 80},
      streakDays: _streakDays,
      lastActivityDate: DateTime.now(),
    );
  }
}
