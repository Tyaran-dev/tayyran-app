import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// =======================
/// BuildContext Extensions
/// =======================
extension ContextX on BuildContext {
  // Screen size
  Size get mediaSize => MediaQuery.of(this).size;
  double get screenHeight => mediaSize.height;
  double get screenWidth => mediaSize.width;

  // Percentages
  double widthPct(double fraction) => screenWidth * fraction;
  double heightPct(double fraction) => screenHeight * fraction;

  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  // SafeArea insets (for notches & nav bars)
  double get safeTop => MediaQuery.of(this).padding.top;
  double get safeBottom => MediaQuery.of(this).padding.bottom;
  double get safeLeft => MediaQuery.of(this).padding.left;
  double get safeRight => MediaQuery.of(this).padding.right;

  // Navigation helpers
  Future<T?> pushPage<T>(Widget page) =>
      Navigator.push(this, MaterialPageRoute(builder: (_) => page));

  void popPage<T extends Object?>([T? result]) => Navigator.pop(this, result);

  Future<T?> pushReplacementPage<T, TO>(Widget page) =>
      Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));

  // Snackbar
  void showSnack(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}

/// =======================
/// Widget Extensions
/// =======================
extension WidgetX on Widget {
  // Padding
  Widget withPadding([EdgeInsetsGeometry padding = const EdgeInsets.all(8)]) =>
      Padding(padding: padding, child: this);

  // Margin (via Container)
  Widget withMargin([EdgeInsetsGeometry margin = const EdgeInsets.all(8)]) =>
      Container(margin: margin, child: this);

  // Background (via Container)
  Widget withBackground(Color color, {EdgeInsetsGeometry? padding}) =>
      Container(color: color, padding: padding, child: this);

  // Rounded corners
  Widget withRoundedBorder([double radius = 12]) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  // Expanded
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);

  // Center
  Widget centered() => Center(child: this);
}

/// =======================
/// Spacing Extensions
/// =======================
extension SpacingX on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}

/// =======================
/// String Extensions
/// =======================
extension StringX on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  String get capitalize {
    if (this == null || this!.isEmpty) return '';
    return this![0].toUpperCase() + this!.substring(1);
  }
}

/// =======================
/// DateTime Extensions
/// =======================
extension DateTimeX on DateTime {
  /// Format: dd/MM/yyyy
  String get ddMMyyyy => DateFormat('dd/MM/yyyy').format(this);

  /// Format: hh:mm a (AM/PM)
  String get hhmmAmPm => DateFormat('hh:mm a').format(this);

  /// Short date e.g. "13 Sep 2025"
  String get toShortDate => DateFormat('d MMM yyyy').format(this);

  /// Long date e.g. "Saturday, 13 September 2025"
  String get toLongDate => DateFormat('EEEE, d MMMM yyyy').format(this);
}

/// =======================
/// Duration Extensions
/// =======================
extension DurationX on num {
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
  Duration get ms => Duration(milliseconds: toInt());
}

/// =======================
/// Iterable / List Extensions
/// =======================
extension IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  T? elementAtOrNull(int index) =>
      (index < 0 || index >= length) ? null : elementAt(index);

  String joinWith([String separator = ', ']) => join(separator);
}

/// =======================
/// Future Extensions
/// =======================
extension FutureX<T> on Future<T> {
  Future<T> delay(Duration duration) async {
    await Future.delayed(duration);
    return this;
  }
}

/// =======================
/// Num Extensions
/// =======================
extension NumX on num {
  bool get isEvenNum => this % 2 == 0;
  bool get isOddNum => this % 2 != 0;

  double get toRadians => (this * 3.141592653589793) / 180.0;
  double get toDegrees => (this * 180.0) / 3.141592653589793;
}

/// =======================
/// Color Extensions
/// =======================
extension ColorX on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// HEX string with alpha (#AARRGGBB)
  String get hex {
    final aHex = a.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final rHex = r.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final gHex = g.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final bHex = b.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$aHex$rHex$gHex$bHex';
  }

  /// HEX string without alpha (#RRGGBB)
  String get hexRGB {
    final rHex = r.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final gHex = g.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final bHex = b.round().toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$rHex$gHex$bHex';
  }
}

/// =======================
/// Nullable Widget Extensions
/// =======================
extension NullableWidgetX on Widget? {
  Widget orEmpty() => this ?? const SizedBox.shrink();
}

extension CabinClassExtensions on String {
  String get toCabinClassDisplayName {
    switch (this) {
      case 'PREMIUM_ECONOMY':
        return 'premium_economy'.tr();
      case 'BUSINESS':
        return 'business'.tr();
      case 'FIRST':
        return 'first'.tr();
      case 'ECONOMY':
      default:
        return 'economy'.tr();
    }
  }

  //   String get toCabinClassBackendValue {
  //     switch (this) {
  //       case 'premium_economy': // This is the translation key, not the translated text
  //       case 'Premium Economy':
  //       case 'اقتصادية متميزة': // Arabic translation
  //         return 'PREMIUM_ECONOMY';
  //       case 'business': // Translation key
  //       case 'Business':
  //       case 'رجال الأعمال': // Arabic translation
  //         return 'BUSINESS';
  //       case 'first': // Translation key
  //       case 'First':
  //       case 'درجة أولى': // Arabic translation
  //         return 'FIRST';
  //       case 'economy': // Translation key
  //       case 'Economy':
  //       case 'اقتصادي': // Arabic translation
  //       default:
  //         return 'ECONOMY';
  //     }
  //   }
}
// extension CabinClassExtensions on String {
//   String get toCabinClassDisplayName {
//     switch (this) {
//       case 'PREMIUM_ECONOMY':
//         return 'premium_economy';
//       case 'BUSINESS':
//         return 'Business';
//       case 'FIRST':
//         return 'first';
//       case 'ECONOMY':
//       default:
//         return 'economy';
//     }
//   }

//   String get toCabinClassBackendValue {
//     switch (this) {
//       case 'Premium Economy':
//         return 'PREMIUM_ECONOMY';
//       case 'Business':
//         return 'BUSINESS';
//       case 'First':
//         return 'FIRST';
//       case 'Economy':
//       default:
//         return 'ECONOMY';
//     }
//   }
// }

extension ElevationToBoxDecoration on double {
  BoxDecoration toBoxDecoration({
    Color color = Colors.white,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(4),
    ),
  }) {
    final Map<double, BoxShadow> elevationMap = {
      0: BoxShadow(color: Colors.transparent),
      1: BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 4.0,
        offset: const Offset(0, 2),
      ),
      2: BoxShadow(
        color: Colors.black.withValues(alpha: 0.14),
        blurRadius: 5.0,
        offset: const Offset(0, 3),
      ),
      3: BoxShadow(
        color: Colors.black.withValues(alpha: 0.16),
        blurRadius: 6.0,
        offset: const Offset(0, 3),
      ),
      4: BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 7.0,
        offset: const Offset(0, 4),
      ),
      6: BoxShadow(
        color: Colors.black.withValues(alpha: 0.20),
        blurRadius: 10.0,
        offset: const Offset(0, 6),
      ),
      8: BoxShadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 12.0,
        offset: const Offset(0, 8),
      ),
      12: BoxShadow(
        color: Colors.black.withValues(alpha: 0.24),
        blurRadius: 16.0,
        offset: const Offset(0, 12),
      ),
      16: BoxShadow(
        color: Colors.black.withValues(alpha: 0.26),
        blurRadius: 20.0,
        offset: const Offset(0, 16),
      ),
      24: BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        blurRadius: 24.0,
        offset: const Offset(0, 24),
      ),
    };

    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      boxShadow: [elevationMap[this] ?? elevationMap[3]!],
    );
  }
}
