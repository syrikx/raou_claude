import 'package:intl/intl.dart';

/// 날짜와 시간 처리를 위한 유틸리티 클래스
class DateTimeHelper {
  
  // ==================== 기본 포맷터 ====================
  static final DateFormat _defaultFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _shortFormatter = DateFormat('MM/dd HH:mm');
  static final DateFormat _dateOnlyFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeOnlyFormatter = DateFormat('HH:mm:ss');
  static final DateFormat _koreanFormatter = DateFormat('yyyy년 MM월 dd일');
  static final DateFormat _koreanWithTimeFormatter = DateFormat('yyyy년 MM월 dd일 HH시 mm분');
  
  // ==================== 포맷팅 메서드 ====================
  
  /// 기본 형식으로 날짜 포맷팅 (yyyy-MM-dd HH:mm:ss)
  static String format(DateTime dateTime) {
    return _defaultFormatter.format(dateTime);
  }
  
  /// 짧은 형식으로 날짜 포맷팅 (MM/dd HH:mm)
  static String formatShort(DateTime dateTime) {
    return _shortFormatter.format(dateTime);
  }
  
  /// 날짜만 포맷팅 (yyyy-MM-dd)
  static String formatDateOnly(DateTime dateTime) {
    return _dateOnlyFormatter.format(dateTime);
  }
  
  /// 시간만 포맷팅 (HH:mm:ss)
  static String formatTimeOnly(DateTime dateTime) {
    return _timeOnlyFormatter.format(dateTime);
  }
  
  /// 한국어 형식으로 날짜 포맷팅 (yyyy년 MM월 dd일)
  static String formatKorean(DateTime dateTime) {
    return _koreanFormatter.format(dateTime);
  }
  
  /// 한국어 형식으로 날짜와 시간 포맷팅 (yyyy년 MM월 dd일 HH시 mm분)
  static String formatKoreanWithTime(DateTime dateTime) {
    return _koreanWithTimeFormatter.format(dateTime);
  }
  
  /// 커스텀 패턴으로 포맷팅
  static String formatCustom(DateTime dateTime, String pattern) {
    return DateFormat(pattern).format(dateTime);
  }
  
  // ==================== 파싱 메서드 ====================
  
  /// 문자열을 DateTime으로 파싱 (기본 형식)
  static DateTime? parse(String dateString) {
    try {
      return _defaultFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// ISO 8601 형식 문자열을 DateTime으로 파싱
  static DateTime? parseIso(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }
  
  /// 커스텀 패턴으로 파싱
  static DateTime? parseCustom(String dateString, String pattern) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // ==================== 상대적 시간 ====================
  
  /// 현재 시간으로부터 상대적 시간 표시 (예: "3분 전", "2시간 전")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1일 전';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}주 전';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}개월 전';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}년 전';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inSeconds > 10) {
      return '${difference.inSeconds}초 전';
    } else {
      return '방금 전';
    }
  }
  
  /// 미래 시간에 대한 상대적 시간 표시 (예: "3분 후", "2시간 후")
  static String getRelativeTimeFuture(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return getRelativeTime(dateTime);
    }
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1일 후';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 후';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}주 후';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}개월 후';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}년 후';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else if (difference.inSeconds > 10) {
      return '${difference.inSeconds}초 후';
    } else {
      return '곧';
    }
  }
  
  // ==================== 날짜 계산 ====================
  
  /// 오늘인지 확인
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }
  
  /// 어제인지 확인
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }
  
  /// 이번 주인지 확인
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return dateTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
           dateTime.isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }
  
  /// 이번 달인지 확인
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }
  
  /// 올해인지 확인
  static bool isThisYear(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year;
  }
  
  // ==================== 유틸리티 메서드 ====================
  
  /// 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }
  
  /// 날짜의 시작 시간 (00:00:00)
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  /// 날짜의 끝 시간 (23:59:59)
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }
  
  /// 월의 첫 날
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }
  
  /// 월의 마지막 날
  static DateTime endOfMonth(DateTime dateTime) {
    final nextMonth = dateTime.month == 12
        ? DateTime(dateTime.year + 1, 1, 1)
        : DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }
  
  /// 타임스탬프를 안전한 파일명으로 변환
  static String toSafeFileName(DateTime dateTime) {
    return formatCustom(dateTime, 'yyyy_MM_dd_HH_mm_ss');
  }
  
  /// 현재 시간의 타임스탬프 (밀리초)
  static int nowTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
  
  /// 타임스탬프에서 DateTime으로 변환
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// 스마트 날짜 표시 (오늘/어제/날짜)
  static String smartFormat(DateTime dateTime) {
    if (isToday(dateTime)) {
      return '오늘 ${formatTimeOnly(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return '어제 ${formatTimeOnly(dateTime)}';
    } else if (isThisYear(dateTime)) {
      return formatCustom(dateTime, 'MM/dd HH:mm');
    } else {
      return formatCustom(dateTime, 'yyyy/MM/dd');
    }
  }
}