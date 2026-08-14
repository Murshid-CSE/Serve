import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyAlertDetailScreen extends ConsumerStatefulWidget {

  const EmergencyAlertDetailScreen({
    super.key,
    required this.alertId,
  });
  final String alertId;

  @override
  ConsumerState<EmergencyAlertDetailScreen> createState() => _EmergencyAlertDetailScreenState();
}

class _EmergencyAlertDetailScreenState extends ConsumerState<EmergencyAlertDetailScreen> {
  bool _isActionLoading = false;

  Future<void> _handleRespond(String userId) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Respond to Emergency?',
      message: 'Are you sure you want to volunteer as a responder? Please only proceed if you are nearby and capable of providing rescue/support assistance safely.',
    );

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await ref.read(emergencyActionsProvider).respondToEmergency(
            alertId: widget.alertId,
            userId: userId,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Thank you for responding! Please coordinate safely.');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        context.showErrorSnackBar('Could not dial contact number: $phone');
      }
    }
  }

  Color _getAlertColor(String level) {
    return switch (level) {
      'critical' => AppColors.emergency,
      'warning' => AppColors.secondary,
      _ => AppColors.info,
    };
  }

  Color _getAlertSurfaceColor(String level) {
    return switch (level) {
      'critical' => AppColors.emergencySurface,
      'warning' => AppColors.secondarySurface,
      _ => AppColors.infoSurface,
    };
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(nearbyEmergencyAlertsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          final alerts = alertsAsync.value ?? [];
          final alertIndex = alerts.indexWhere((a) => a.id == widget.alertId);
          if (alertIndex == -1) {
            return const Center(child: Text('Emergency alert not found.'));
          }

          final alert = alerts[alertIndex];
          final hasResponded = alert.responders.contains(user.uid);
          final alertColor = _getAlertColor(alert.level);
          final surfaceColor = _getAlertSurfaceColor(alert.level);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Severity tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: alertColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${alert.level.toUpperCase()} INCIDENT',
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Posted duration
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reported: ${alert.createdAt.timeAgo}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const Divider(height: 32, color: AppColors.neutral200),

                  // Description
                  const Text(
                    'Incident Description',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location
                  const Text(
                    'Incident Address / Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: alertColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alert.address,
                            style: const TextStyle(fontSize: 13, color: AppColors.neutral700, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Person (SOS Coordinator)
                  if (alert.contactPhone.isNotEmpty) ...[
                    const Text(
                      'Emergency Contact',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: alertColor.withValues(alpha: 0.12),
                            child: Icon(Icons.phone_android_rounded, color: alertColor),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reporter Contact',
                                  style: TextStyle(fontSize: 11, color: AppColors.neutral600),
                                ),
                                Text(
                                  'SOS Coordinator',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _makeCall(alert.contactPhone),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.successSurface,
                              foregroundColor: AppColors.success,
                            ),
                            icon: const Icon(Icons.phone_in_talk_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],

                  // Action Buttons
                  if (hasResponded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.success),
                          SizedBox(width: 10),
                          Text(
                            'You have responded as ACTIVE rescuer.',
                            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else
                    AppButton(
                      label: 'Respond to Alert / I Can Help',
                      onPressed: _isActionLoading ? null : () => _handleRespond(user.uid),
                      isLoading: _isActionLoading,
                      isExpanded: true,
                      variant: AppButtonVariant.filled,
                      color: alertColor,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingShimmer.detail(),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }
}
