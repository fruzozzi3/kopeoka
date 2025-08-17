// lib/theme/color.dart
import 'package:flutter/material.dart';

// Цвета
const Color kPrimary = Color(0xFF6750A4); // фиолетовый акцент
const Color kOnPrimary = Colors.white;
const Color kCard = Colors.white;
const Color kBg = Color(0xFFF5F6FA); // светло-серый фон
const Color kTextPrimary = Color(0xFF1F1F1F);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kSuccess = Color(0xFF4CAF50); // Зеленый для успеха
const Color kError = Color(0xFFF44336); // Красный для ошибок
const Color kWarning = Color(0xFFFFC107); // Желтый для предупреждений
const Color kInfo = Color(0xFF2196F3); // Голубой для информации

// Темная тема
const Color kPrimaryDark = Color(0xFFB39DDB);
const Color kCardDark = Color(0xFF1F1F1F);
const Color kBgDark = Color(0xFF121212);
const Color kTextPrimaryDark = Colors.white;
const Color kTextSecondaryDark = Color(0xFFB0B0B0);
const Color kSuccessDark = Color(0xFF66BB6A);
const Color kErrorDark = Color(0xFFEF5350);
const Color kWarningDark = Color(0xFFFFD54F);
const Color kInfoDark = Color(0xFF64B5F6);

// Светлая тема
const Color kPrimaryLight = kPrimary;
const Color kCardLight = kCard;
const Color kBgLight = kBg;
const Color kTextPrimaryLight = kTextPrimary;
const Color kTextSecondaryLight = kTextSecondary;
const Color kSuccessLight = kSuccess;
const Color kErrorLight = kError;
const Color kWarningLight = kWarning;
const Color kInfoLight = kInfo;

// Градиенты
const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6750A4), Color(0xFF8B6CBF)],
);
const LinearGradient kSuccessGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kSuccess, kSuccessDark],
);
const LinearGradient kErrorGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kError, kErrorDark],
);
const LinearGradient kPrimaryGradientLight = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryLight, Color(0xFF8B6CBF)],
);
const LinearGradient kPrimaryGradientDark = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryDark, Color(0xFF9575CD)],
);
// Теневые эффекты
List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    offset: const Offset(0, 5),
    blurRadius: 10,
  ),
];
