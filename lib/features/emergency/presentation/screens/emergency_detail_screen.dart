import 'package:flutter/material.dart';
import 'package:community_care_hub/features/emergency/presentation/screens/emergency_alert_detail_screen.dart';

class EmergencyDetailScreen extends StatelessWidget {

  const EmergencyDetailScreen({
    super.key,
    required this.emergencyId,
  });
  final String emergencyId;

  @override
  Widget build(BuildContext context) {
    return EmergencyAlertDetailScreen(alertId: emergencyId);
  }
}
