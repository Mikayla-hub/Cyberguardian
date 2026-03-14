import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';
import 'package:phishguard_ai/features/incident/presentation/providers/incident_provider.dart';

class IncidentResponseScreen extends ConsumerStatefulWidget {
  const IncidentResponseScreen({super.key});

  @override
  ConsumerState<IncidentResponseScreen> createState() =>
      _IncidentResponseScreenState();
}

class _IncidentResponseScreenState extends ConsumerState<IncidentResponseScreen> {
  String _selectedIncidentType = 'emailPhishing';

  @override
  Widget build(BuildContext context) {
    final incidentState = ref.watch(incidentProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role ?? UserRole.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Response'),
      ),
      body: incidentState.status == IncidentStatus.initial
          ? _IncidentTypeSelector(
              selectedType: _selectedIncidentType,
              userRole: userRole,
              onTypeChanged: (type) => setState(() => _selectedIncidentType = type),
              onStart: () {
                ref.read(incidentProvider.notifier).loadResponsePlan(
                      incidentType: _selectedIncidentType,
                      userRole: userRole,
                    );
              },
            )
          : incidentState.status == IncidentStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : incidentState.status == IncidentStatus.error
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(incidentState.errorMessage ?? 'An error occurred'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(incidentProvider.notifier).loadResponsePlan(
                                  incidentType: _selectedIncidentType,
                                  userRole: userRole,
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _ResponsePlanView(
                      response: incidentState.response!,
                      selectedPhase: incidentState.selectedPhase,
                      emergencyContacts: incidentState.emergencyContacts,
                      showEscalation: incidentState.showEscalation,
                      onPhaseSelected: (phase) {
                        ref.read(incidentProvider.notifier).selectPhase(phase);
                      },
                      onStepCompleted: (stepId) {
                        ref.read(incidentProvider.notifier).completeStep(stepId);
                      },
                    ),
    );
  }
}

class _IncidentTypeSelector extends StatelessWidget {
  final String selectedType;
  final UserRole userRole;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onStart;

  const _IncidentTypeSelector({
    required this.selectedType,
    required this.userRole,
    required this.onTypeChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = [
      ('emailPhishing', 'Email Phishing', Icons.email_outlined, AppColors.riskHigh),
      ('websiteSpoofing', 'Website Spoofing', Icons.language, AppColors.riskMedium),
      ('smsPhishing', 'SMS Phishing', Icons.sms_outlined, AppColors.warning),
      ('socialEngineering', 'Social Engineering', Icons.people_outline, AppColors.riskCritical),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of incident?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the type of phishing incident to get a step-by-step response plan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your role: ${userRole.name.toUpperCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...types.map(
            (type) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selectedType == type.$1
                      ? type.$4
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.$4.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(type.$3, color: type.$4),
                ),
                title: Text(type.$2),
                trailing: selectedType == type.$1
                    ? Icon(Icons.check_circle, color: type.$4)
                    : null,
                onTap: () => onTypeChanged(type.$1),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Get Response Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsePlanView extends StatelessWidget {
  final IncidentResponse response;
  final IncidentPhase selectedPhase;
  final List<EmergencyContact> emergencyContacts;
  final bool showEscalation;
  final ValueChanged<IncidentPhase> onPhaseSelected;
  final ValueChanged<String> onStepCompleted;

  const _ResponsePlanView({
    required this.response,
    required this.selectedPhase,
    required this.emergencyContacts,
    required this.showEscalation,
    required this.onPhaseSelected,
    required this.onStepCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = response.getStepsForPhase(selectedPhase);

    return Column(
      children: [
        // Escalation banner
        if (showEscalation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.riskCritical.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.warning, color: AppColors.riskCritical, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ESCALATION REQUIRED: ${response.escalationReason ?? "High-risk incident detected"}',
                    style: const TextStyle(
                      color: AppColors.riskCritical,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    response.phaseLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${response.completedSteps}/${response.totalSteps} steps',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: response.completionPercentage,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Phase selector
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: IncidentPhase.values.map((phase) {
              final isSelected = phase == selectedPhase;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(_phaseLabel(phase)),
                  onSelected: (_) => onPhaseSelected(phase),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Timeline steps
        Expanded(
          child: steps.isEmpty
              ? Center(
                  child: Text(
                    'No steps for this phase',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: steps.length + (emergencyContacts.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == steps.length && emergencyContacts.isNotEmpty) {
                      return _EmergencyContactsCard(contacts: emergencyContacts);
                    }

                    final step = steps[index];
                    final isLast = index == steps.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline line
                          SizedBox(
                            width: 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: step.isCompleted
                                        ? AppColors.riskSafe
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                  ),
                                  child: step.isCompleted
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : Center(
                                          child: Text(
                                            '${step.order}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: step.isCompleted
                                          ? AppColors.riskSafe.withValues(alpha: 0.3)
                                          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            step.title,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              decoration: step.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (!step.isCompleted)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline,
                                                size: 20),
                                            onPressed: () => onStepCompleted(step.id),
                                            color: AppColors.primary,
                                          ),
                                      ],
                                    ),
                                    Text(
                                      step.description,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.assignment_outlined,
                                              size: 14, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              step.actionRequired,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (step.estimatedDuration != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 14,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '~${step.estimatedDuration!.inMinutes} min',
                                              style: theme.textTheme.bodySmall,
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _phaseLabel(IncidentPhase phase) {
    switch (phase) {
      case IncidentPhase.identification:
        return 'Identify';
      case IncidentPhase.containment:
        return 'Contain';
      case IncidentPhase.reporting:
        return 'Report';
      case IncidentPhase.recovery:
        return 'Recover';
      case IncidentPhase.postIncidentReview:
        return 'Review';
    }
  }
}

class _EmergencyContactsCard extends StatelessWidget {
  final List<EmergencyContact> contacts;

  const _EmergencyContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.riskCritical.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: AppColors.riskCritical),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.riskCritical,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...contacts.map(
              (contact) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${contact.role} - ${contact.phone}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_outlined, size: 20),
                      onPressed: () {},
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
