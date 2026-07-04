import 'package:flutter/material.dart';

/// A compact pill-shaped chip that displays a status label with contextual
/// colour coding and a leading dot indicator.
///
/// The colour is resolved automatically from the [status] string:
///
/// | Statuses                                      | Colour  |
/// |-----------------------------------------------|---------|
/// | pending, available                             | amber   |
/// | active, accepted, responding                   | blue    |
/// | in_progress, collected                         | indigo  |
/// | completed, fulfilled, delivered, resolved      | green   |
/// | expired, cancelled                             | grey    |
/// | open                                           | teal    |
/// | emergency, critical                            | red     |
///
/// ```dart
/// StatusChip(status: 'Available')
/// ```
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  /// The status label displayed inside the chip.
  final String status;

  @override
  Widget build(BuildContext context) {
    final colours = _resolveColours(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colours.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colours.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _displayLabel(status),
            style: TextStyle(
              color: colours.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Converts a raw status key (e.g. `in_progress`) to a human-friendly
  /// display label (e.g. `In Progress`).
  static String _displayLabel(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static _StatusColours _resolveColours(String status) {
    switch (status.toLowerCase().replaceAll(' ', '_')) {
      // Amber — awaiting action
      case 'pending':
      case 'available':
        return const _StatusColours(
          foreground: Color(0xFFF57F17),
          background: Color(0xFFFFF8E1),
        );

      // Blue — actively in progress / accepted
      case 'active':
      case 'accepted':
      case 'responding':
        return const _StatusColours(
          foreground: Color(0xFF1565C0),
          background: Color(0xFFE3F2FD),
        );

      // Indigo — mid-workflow steps
      case 'in_progress':
      case 'collected':
        return const _StatusColours(
          foreground: Color(0xFF283593),
          background: Color(0xFFE8EAF6),
        );

      // Green — terminal success states
      case 'completed':
      case 'fulfilled':
      case 'delivered':
      case 'resolved':
        return const _StatusColours(
          foreground: Color(0xFF2E7D32),
          background: Color(0xFFE8F5E9),
        );

      // Grey — inactive / ended
      case 'expired':
      case 'cancelled':
      case 'closed':
        return const _StatusColours(
          foreground: Color(0xFF616161),
          background: Color(0xFFF5F5F5),
        );

      // Teal — open / awaiting volunteers
      case 'open':
        return const _StatusColours(
          foreground: Color(0xFF00695C),
          background: Color(0xFFE0F2F1),
        );

      // Red — emergency / critical
      case 'emergency':
      case 'critical':
        return const _StatusColours(
          foreground: Color(0xFFC62828),
          background: Color(0xFFFFEBEE),
        );

      // Fallback — neutral
      default:
        return const _StatusColours(
          foreground: Color(0xFF757575),
          background: Color(0xFFF5F5F5),
        );
    }
  }
}

/// Simple value object holding the foreground and background colours
/// used by [StatusChip].
class _StatusColours {
  const _StatusColours({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
