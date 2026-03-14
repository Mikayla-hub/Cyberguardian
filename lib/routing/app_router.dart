import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:phishguard_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:phishguard_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:phishguard_ai/features/incident/presentation/screens/incident_response_screen.dart';
import 'package:phishguard_ai/features/learning/presentation/screens/learning_hub_screen.dart';
import 'package:phishguard_ai/features/learning/presentation/screens/lesson_detail_screen.dart';
import 'package:phishguard_ai/features/report/presentation/screens/report_phishing_screen.dart';
import 'package:phishguard_ai/features/scan/presentation/screens/scan_screen.dart';
import 'package:phishguard_ai/routing/shell_scaffold.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String scan = '/scan';
  static const String learning = '/learning';
  static const String lessonDetail = '/learning/:lessonId';
  static const String report = '/report';
  static const String incident = '/incident';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.scan,
            name: 'scan',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ScanScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.learning,
            name: 'learning',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LearningHubScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              GoRoute(
                path: ':lessonId',
                name: 'lessonDetail',
                builder: (context, state) {
                  final lessonId = state.pathParameters['lessonId']!;
                  return LessonDetailScreen(lessonId: lessonId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.incident,
            name: 'incident',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const IncidentResponseScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.report,
        name: 'report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ReportPhishingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
