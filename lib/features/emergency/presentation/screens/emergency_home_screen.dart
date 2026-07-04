import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:community_care_hub/features/emergency/presentation/widgets/emergency_card.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHomeScreen extends ConsumerWidget {
  const EmergencyHomeScreen({super.key});

  Future<void> _callEmergencyHotline(BuildContext context) async {
    final Uri url = Uri.parse('tel:112'); // National emergency number India
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer for hotline 112.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(nearbyEmergencyAlertsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.emergency,
              primaryContainer: AppColors.emergencySurface,
              onPrimaryContainer: AppColors.emergencyDark,
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Response', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('User session missing.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgent Emergency Broadcast Dial Banner
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.emergency,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emergency.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_rounded, color: Colors.white, size: 28),
                            SizedBox(width: 10),
                            Text(
                              'Emergency Hotline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'If you are in immediate danger or need urgent medical/rescue assistance, dial emergency response services now.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => _callEmergencyHotline(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.emergencyDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.phone_in_talk_rounded),
                          label: const Text(
                            'Call SOS Services (112)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Active Incidents Nearby',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),

                // Alerts list
                Expanded(
                  child: alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return const EmptyState(
                          icon: Icons.shield_rounded,
                          title: 'All Clear',
                          subtitle: 'There are no active emergency alerts listed in your immediate range.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(nearbyEmergencyAlertsProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            double? dist;
                            if (user.hasLocation) {
                              dist = GeoUtils.calculateDistance(
                                user.latitude,
                                user.longitude,
                                alert.latitude,
                                alert.longitude,
                              );
                            }

                            return EmergencyCard(
                              alert: alert,
                              distanceKm: dist,
                              onTap: () {
                                context.push('/emergency/${alert.id}');
                              },
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LoadingShimmer.list(count: 3),
                    ),
                    error: (err, stack) => ErrorState(
                      message: err.toString(),
                      onRetry: () => ref.invalidate(nearbyEmergencyAlertsProvider),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorState(message: err.toString()),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.createEmergency),
          backgroundColor: AppColors.emergency,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_alert_rounded),
          label: const Text('Report Emergency', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
