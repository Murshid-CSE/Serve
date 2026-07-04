import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 0;
  String _category = 'general';
  bool _isLoading = false;

  static const _categories = [
    {'value': 'general', 'label': 'General', 'icon': Icons.chat_bubble_outline_rounded},
    {'value': 'bug', 'label': 'Bug Report', 'icon': Icons.bug_report_rounded},
    {'value': 'feature', 'label': 'Feature Request', 'icon': Icons.lightbulb_rounded},
    {'value': 'improvement', 'label': 'Improvement', 'icon': Icons.trending_up_rounded},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      context.showErrorSnackBar('Please give a rating');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('User not found');

      await FirebaseFirestore.instance
          .collection(FirebaseConstants.feedbackCollection)
          .add({
        'userId': user.uid,
        'userName': user.name,
        'userEmail': user.email,
        'rating': _rating,
        'category': _category,
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      context.showSuccessSnackBar('Thank you for your feedback!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to submit feedback: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating
              Text(
                'How would you rate your experience?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 44,
                        color: starIndex <= _rating ? AppColors.warning : AppColors.neutral400,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _category == cat['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 18,
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(cat['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Message
              AppTextField(
                controller: _messageController,
                label: 'Your Feedback',
                hint: 'Tell us what you think...',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 6,
                validator: Validators.required,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Submit
              AppButton(
                label: _isLoading ? 'Submitting...' : 'Submit Feedback',
                onPressed: _isLoading ? null : _submitFeedback,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
