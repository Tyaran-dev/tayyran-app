// modify_search_state.dart

class ModifySearchState {
  final String from;
  final String to;
  final String departureDate;
  final String returnDate;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final bool hasReturnDate;
  final bool showDateError;

  const ModifySearchState({
    required this.from,
    required this.to,
    required this.departureDate,
    required this.returnDate,
    required this.adults,
    required this.children,
    required this.infants,
    required this.cabinClass,
    required this.hasReturnDate,
    required this.showDateError,
  });

  factory ModifySearchState.initial(Map<String, dynamic> initialData) {
    return ModifySearchState(
      from: initialData['from'] ?? '',
      to: initialData['to'] ?? '',
      departureDate: initialData['departureDate'] ?? '',
      returnDate: initialData['returnDate'] ?? '',
      adults: initialData['adults'] is int ? initialData['adults'] : 1,
      children: initialData['children'] is int ? initialData['children'] : 0,
      infants: initialData['infants'] is int ? initialData['infants'] : 0,
      cabinClass: initialData['cabinClass'] is String
          ? initialData['cabinClass']
          : 'Economy',
      hasReturnDate: (initialData['returnDate'] ?? '').isNotEmpty,
      showDateError: false,
    );
  }

  ModifySearchState copyWith({
    String? from,
    String? to,
    String? departureDate,
    String? returnDate,
    int? adults,
    int? children,
    int? infants,
    String? cabinClass,
    bool? hasReturnDate,
    bool? showDateError,
  }) {
    return ModifySearchState(
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabinClass: cabinClass ?? this.cabinClass,
      hasReturnDate: hasReturnDate ?? this.hasReturnDate,
      showDateError: showDateError ?? this.showDateError,
    );
  }

  Map<String, dynamic> toSearchData() {
    return {
      'from': from,
      'to': to,
      'departureDate': departureDate,
      'returnDate': hasReturnDate ? returnDate : '',
      'adults': adults,
      'children': children,
      'infants': infants,
      'cabinClass': cabinClass,
      'type': hasReturnDate ? 'round' : 'oneway',
    };
  }
}
