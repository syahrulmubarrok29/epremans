import 'package:flutter/material.dart';

/// e-PREMANS color palette.
///
/// All colors are defined here and consumed through [AppTheme].
/// Do not use raw hex values elsewhere — always reference these constants.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand / Primary
  // ---------------------------------------------------------------------------

  /// Primary brand color — deep professional blue used for main UI chrome.
  static const Color primary = Color(0xFF1A3A5C);

  /// Lighter variant used for hover / selected states.
  static const Color primaryLight = Color(0xFF2E5F8A);

  /// Dark variant used for pressed states / elevated surfaces.
  static const Color primaryDark = Color(0xFF0F2237);

  // ---------------------------------------------------------------------------
  // Accent / Secondary
  // ---------------------------------------------------------------------------

  /// Accent color — teal, conveys health/technology.
  static const Color accent = Color(0xFF00A8A8);

  /// Lighter accent for chips, badges, highlights.
  static const Color accentLight = Color(0xFF4DCCCC);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF01579B);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ---------------------------------------------------------------------------
  // Neutral / Surface
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFECF0F5);

  static const Color divider = Color(0xFFDDE3EB);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF1A2330);
  static const Color textSecondary = Color(0xFF5A6578);
  static const Color textDisabled = Color(0xFFAEB8C5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Status badges (for request/task statuses)
  // ---------------------------------------------------------------------------

  static const Color statusPending = Color(0xFFF57F17);
  static const Color statusPendingBg = Color(0xFFFFF8E1);

  static const Color statusInProgress = Color(0xFF0288D1);
  static const Color statusInProgressBg = Color(0xFFE1F5FE);

  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCompletedBg = Color(0xFFE8F5E9);

  static const Color statusCancelled = Color(0xFF757575);
  static const Color statusCancelledBg = Color(0xFFF5F5F5);
}
