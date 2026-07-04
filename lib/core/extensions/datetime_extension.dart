import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtension on DateTime {
  /// Returns a human-readable relative time string such as
  /// "2 minutes ago", "1 hour ago", or "just now".
  String get timeAgo => timeago.format(this, allowFromNow: false);

  /// Formats as "Jun 27, 2026".
  String get formatDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Formats as "2:30 PM".
  String get formatTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Formats as "Jun 27, 2026 at 2:30 PM".
  String get formatDateTime => '$formatDate at $formatTime';

  /// Returns `true` if this [DateTime] is before [DateTime.now].
  bool get isExpired => isBefore(DateTime.now());

  /// Returns the [Duration] remaining until this [DateTime].
  /// Returns [Duration.zero] if the datetime is already in the past.
  Duration get remainingDuration {
    final diff = difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Returns `true` if this [DateTime] falls on today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns `true` if this [DateTime] falls on yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns `true` if this [DateTime] falls within the current
  /// ISO week (Monday through Sunday).
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return !isBefore(start) && isBefore(end);
  }

  /// Returns a user-friendly expiry string such as
  /// "Expires in 2h 30m" or "Expired".
  String get formatRelativeExpiry {
    final remaining = remainingDuration;
    if (remaining == Duration.zero) return 'Expired';

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    if (days > 0) {
      return 'Expires in ${days}d ${hours}h';
    }
    if (hours > 0) {
      return 'Expires in ${hours}h ${minutes}m';
    }
    return 'Expires in ${minutes}m';
  }
}
