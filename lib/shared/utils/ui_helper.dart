import 'package:flutter/material.dart';

class UIHelper {
  /// ✅ 전역 scaffoldMessengerKey
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// ✅ 전역 navigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// ✅ SnackBar 표시 (context 있으면 context 기반, 없으면 전역)
  static void showSnack(String message,
      {BuildContext? context, int seconds = 2, SnackBarAction? action}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds),
      action: action,
    );

    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } catch (_) {}
    }

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  /// ✅ 성공 메시지 SnackBar (녹색 배경)
  static void showSuccessSnack(String message,
      {BuildContext? context, int seconds = 3}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: seconds),
    );

    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } catch (_) {}
    }

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  /// ✅ 오류 메시지 SnackBar (빨간 배경)
  static void showErrorSnack(String message,
      {BuildContext? context, int seconds = 4}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: seconds),
    );

    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } catch (_) {}
    }

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  /// ✅ 경고 메시지 SnackBar (오렌지 배경)
  static void showWarningSnack(String message,
      {BuildContext? context, int seconds = 3}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: seconds),
    );

    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } catch (_) {}
    }

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  /// ✅ AlertDialog 표시 (context가 없으면 navigatorKey로 표시 시도)
  static Future<void> showDialogBox({
    BuildContext? context,
    required String title,
    required String content,
    String confirmText = 'OK',
  }) async {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    return showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// ✅ 확인/취소 AlertDialog
  static Future<bool> showConfirmDialog({
    BuildContext? context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
  }) async {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return false;

    final result = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// ✅ 일반 페이지 이동
  static Future<T?> navigateTo<T extends Object?>(
    Widget page, {
    BuildContext? context,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);

    return Navigator.push<T>(
      ctx,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// ✅ 현재 페이지 교체 이동
  static Future<T?> navigateReplace<T extends Object?>(
    Widget page, {
    BuildContext? context,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);

    return Navigator.pushReplacement<T, T>(
      ctx,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// ✅ 뒤로 가기
  static void navigateBack<T extends Object?>({
    BuildContext? context,
    T? result,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    Navigator.pop<T>(ctx, result);
  }

  /// ✅ 현재 SnackBar 숨기기
  static void hideCurrentSnackBar({BuildContext? context}) {
    if (context != null) {
      try {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      } catch (_) {}
    }

    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }
}