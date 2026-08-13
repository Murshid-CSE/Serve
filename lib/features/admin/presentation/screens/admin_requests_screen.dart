import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/status_chip.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';

// Providers for each collection
final _foodDonationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.foodDonationsCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final _bloodRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.bloodRequestsCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final _volunteerTasksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.volunteerTasksCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final _emergencyRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.emergencyRequestsCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  ConsumerState<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteDocument(String collection, String docId, String label) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete $label',
      message: 'Are you sure you want to delete this $label? This cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
      if (mounted) context.showSuccessSnackBar('$label deleted.');
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed: $e');
    }
  }

  Future<void> _updateStatus(String collection, String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).update({
        'status': newStatus,
      });
      if (mounted) context.showSuccessSnackBar('Status updated to $newStatus.');
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_rounded), text: 'Food'),
            Tab(icon: Icon(Icons.bloodtype_rounded), text: 'Blood'),
            Tab(icon: Icon(Icons.volunteer_activism_rounded), text: 'Volunteer'),
            Tab(icon: Icon(Icons.emergency_rounded), text: 'Emergency'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RequestList(
            provider: _foodDonationsProvider,
            collection: FirebaseConstants.foodDonationsCollection,
            label: 'Food Donation',
            titleField: 'title',
            subtitleField: 'donorName',
            statusField: 'status',
            onDelete: _deleteDocument,
            onUpdateStatus: _updateStatus,
            statusOptions: const ['available', 'accepted', 'collected', 'delivered', 'completed', 'expired'],
            moduleColor: AppColors.foodModule,
          ),
          _RequestList(
            provider: _bloodRequestsProvider,
            collection: FirebaseConstants.bloodRequestsCollection,
            label: 'Blood Request',
            titleField: 'patientName',
            subtitleField: 'requesterName',
            statusField: 'status',
            onDelete: _deleteDocument,
            onUpdateStatus: _updateStatus,
            statusOptions: const ['open', 'responding', 'fulfilled', 'cancelled', 'expired'],
            moduleColor: AppColors.bloodModule,
          ),
          _RequestList(
            provider: _volunteerTasksProvider,
            collection: FirebaseConstants.volunteerTasksCollection,
            label: 'Volunteer Task',
            titleField: 'title',
            subtitleField: 'creatorName',
            statusField: 'status',
            onDelete: _deleteDocument,
            onUpdateStatus: _updateStatus,
            statusOptions: const ['active', 'completed', 'cancelled'],
            moduleColor: AppColors.volunteerModule,
          ),
          _RequestList(
            provider: _emergencyRequestsProvider,
            collection: FirebaseConstants.emergencyRequestsCollection,
            label: 'Emergency',
            titleField: 'title',
            subtitleField: 'contactPhone',
            statusField: 'level',
            onDelete: _deleteDocument,
            onUpdateStatus: _updateStatus,
            statusOptions: const ['critical', 'warning', 'info'],
            moduleColor: AppColors.emergencyModule,
          ),
        ],
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {

  const _RequestList({
    required this.provider,
    required this.collection,
    required this.label,
    required this.titleField,
    required this.subtitleField,
    required this.statusField,
    required this.onDelete,
    required this.onUpdateStatus,
    required this.statusOptions,
    required this.moduleColor,
  });
  final StreamProvider<List<Map<String, dynamic>>> provider;
  final String collection;
  final String label;
  final String titleField;
  final String subtitleField;
  final String statusField;
  final Future<void> Function(String, String, String) onDelete;
  final Future<void> Function(String, String, String) onUpdateStatus;
  final List<String> statusOptions;
  final Color moduleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(provider);

    return dataAsync.when(
      loading: () => const LoadingShimmer.list(count: 5),
      error: (error, stack) => ErrorState(
        message: 'Failed to load $label items',
        onRetry: () => ref.invalidate(provider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_rounded,
            title: 'No $label Records',
            subtitle: 'There are no $label records to manage.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(provider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['id'] as String;
              final title = item[titleField] as String? ?? 'Untitled';
              final subtitle = item[subtitleField] as String? ?? '';
              final status = item[statusField] as String? ?? 'unknown';
              final createdAt = (item['createdAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: moduleColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusChip(status: status),
                          const SizedBox(width: 8),
                          if (createdAt != null)
                            Text(
                              createdAt.timeAgo,
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete(collection, id, label);
                      } else {
                        onUpdateStatus(collection, id, value);
                      }
                    },
                    itemBuilder: (context) => [
                      ...statusOptions.map((s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(
                              status == s ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              size: 18,
                              color: status == s ? moduleColor : null,
                            ),
                            const SizedBox(width: 8),
                            Text(s[0].toUpperCase() + s.substring(1)),
                          ],
                        ),
                      )),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.emergency)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
