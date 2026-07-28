import 'package:flutter/material.dart';

/// Semantic color definitions for light and dark themes.
class AppColors {
  AppColors._();

  // --- Primary ---
  static const Color primary = Color(0xFF1565C0); // Blue 800
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);

  // --- Secondary ---
  static const Color secondary = Color(0xFF00897B); // Teal 600
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFA7F5EC);
  static const Color onSecondaryContainer = Color(0xFF002019);

  // --- Tertiary ---
  static const Color tertiary = Color(0xFF7B1FA2); // Purple 700
  static const Color onTertiary = Color(0xFFFFFFFF);

  // --- Error ---
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // --- Success ---
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // --- Warning ---
  static const Color warning = Color(0xFFF57F17);
  static const Color onWarning = Color(0xFFFFFFFF);

  // --- Surface / Background (Light) ---
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);
  static const Color backgroundLight = Color(0xFFFEFBFF);

  // --- Surface / Background (Dark) ---
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);
  static const Color backgroundDark = Color(0xFF121212);

  // --- BLE Status ---
  static const Color bleConnected = Color(0xFF2E7D32);
  static const Color bleDisconnected = Color(0xFF9E9E9E);
  static const Color bleConnecting = Color(0xFFF57F17);

  // --- RSSI ---
  static const Color rssiExcellent = Color(0xFF2E7D32); // RSSI >= -50
  static const Color rssiGood = Color(0xFF689F38); // RSSI >= -65
  static const Color rssiFair = Color(0xFFF57F17); // RSSI >= -80
  static const Color rssiPoor = Color(0xFFD32F2F); // RSSI < -80

  // --- DFU ---
  static const Color dfuProgress = Color(0xFF1565C0);

  // --- Data Direction ---
  static const Color directionTx = Color(0xFF1565C0);
  static const Color directionRx = Color(0xFF00897B);
}
