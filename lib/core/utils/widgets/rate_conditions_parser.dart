// lib/core/utils/rate_conditions_parser.dart
class RateConditionsParser {
  // Extract Check-in Instructions
  static String? extractCheckInInstructions(List<dynamic> rateConditions) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    final checkInInstruction = stringConditions.firstWhere(
      (condition) =>
          condition.contains("CheckIn Instructions:") ||
          condition.contains("Special Instructions :"),
      orElse: () => '',
    );

    if (checkInInstruction.isEmpty) return null;

    String content = checkInInstruction
        .replaceAll("CheckIn Instructions:", "")
        .replaceAll("Special Instructions :", "")
        .trim();

    // Clean HTML tags and special characters
    content = _cleanHtmlContent(content);

    return content.isNotEmpty ? content : null;
  }

  // Extract Fees and Extras
  static Map<String, String?> extractFeesAndExtras(
    List<dynamic> rateConditions,
  ) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    final mandatoryFees = stringConditions.firstWhere(
      (condition) => condition.contains("Mandatory Fees:"),
      orElse: () => '',
    );

    final optionalFees = stringConditions.firstWhere(
      (condition) => condition.contains("Optional Fees:"),
      orElse: () => '',
    );

    return {
      'mandatory': mandatoryFees.isNotEmpty
          ? _processFeeContent(
              mandatoryFees.replaceAll("Mandatory Fees:", "").trim(),
            )
          : null,
      'optional': optionalFees.isNotEmpty
          ? _processFeeContent(
              optionalFees.replaceAll("Optional Fees:", "").trim(),
            )
          : null,
    };
  }

  // Extract Cards Accepted
  static String? extractCardsAccepted(List<dynamic> rateConditions) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    final cardsAccepted = stringConditions.firstWhere(
      (condition) => condition.contains("Cards Accepted:"),
      orElse: () => '',
    );

    if (cardsAccepted.isEmpty) return null;

    return cardsAccepted.replaceAll("Cards Accepted:", "").trim();
  }

  // Extract Check-in/Check-out times
  static Map<String, String> extractCheckTimes(List<dynamic> rateConditions) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    String checkInBegin = '14:00';
    String checkInEnd = 'Anytime';
    String checkOut = '12:00';

    for (final condition in stringConditions) {
      if (condition.contains("CheckIn Time-Begin:")) {
        final match = RegExp(
          r'CheckIn Time-Begin:\s*([\d:]+[APM\s]*)',
        ).firstMatch(condition);
        if (match != null) checkInBegin = match.group(1)!.trim();
      }
      if (condition.contains("CheckIn Time-End:")) {
        final match = RegExp(
          r'CheckIn Time-End:\s*([\w\s:]*)',
        ).firstMatch(condition);
        if (match != null) checkInEnd = match.group(1)!.trim();
      }
      if (condition.contains("CheckOut Time:")) {
        final match = RegExp(
          r'CheckOut Time:\s*([\d:]+[APM\s]*)',
        ).firstMatch(condition);
        if (match != null) checkOut = match.group(1)!.trim();
      }
    }

    return {
      'checkInBegin': checkInBegin,
      'checkInEnd': checkInEnd,
      'checkOut': checkOut,
    };
  }

  // Extract Minimum Check-in Age
  static String? extractMinimumCheckInAge(List<dynamic> rateConditions) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    final minAge = stringConditions.firstWhere(
      (condition) => condition.contains("Minimum CheckIn Age :"),
      orElse: () => '',
    );

    if (minAge.isEmpty) return null;

    return minAge.replaceAll("Minimum CheckIn Age :", "").trim();
  }

  // Process fee content (similar to your backend)
  static String? _processFeeContent(String feeContent) {
    if (feeContent.isEmpty) return null;

    String content = _cleanHtmlContent(feeContent);
    return content.isNotEmpty ? content : null;
  }

  // Clean HTML content (similar to your backend)
  static String _cleanHtmlContent(String content) {
    return content
        .replaceAll(RegExp(r'&lt;ul&gt;'), '')
        .replaceAll(RegExp(r'&lt;\/ul&gt;'), '')
        .replaceAll(RegExp(r'&lt;li&gt;'), '• ')
        .replaceAll(RegExp(r'&lt;\/li&gt;'), '\n')
        .replaceAll(RegExp(r'&lt;p&gt;'), '')
        .replaceAll(RegExp(r'&lt;\/p&gt;'), '\n')
        .replaceAll(RegExp(r'-vib-dip'), '')
        .replaceAll(RegExp(r'-dip-dip'), '')
        .replaceAll(RegExp(r'-dip'), '')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();
  }

  // Extract all important information excluding the structured data
  static List<String> extractGeneralInformation(List<dynamic> rateConditions) {
    final stringConditions = rateConditions
        .whereType<String>()
        .where((condition) => condition.isNotEmpty)
        .toList();

    final excludedPatterns = [
      'CheckIn Instructions:',
      'Special Instructions :',
      'Mandatory Fees:',
      'Optional Fees:',
      'Cards Accepted:',
      'CheckIn Time-Begin:',
      'CheckIn Time-End:',
      'CheckOut Time:',
      'Minimum CheckIn Age :',
    ];

    return stringConditions
        .where(
          (condition) =>
              !excludedPatterns.any((pattern) => condition.contains(pattern)) &&
              condition.length > 10,
        )
        .map((condition) => _cleanHtmlContent(condition))
        .where((condition) => condition.isNotEmpty)
        .toList();
  }
}
