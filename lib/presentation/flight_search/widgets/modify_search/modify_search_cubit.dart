// modify_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/modify_search/modify_search_state.dart';

class ModifySearchCubit extends Cubit<ModifySearchState> {
  ModifySearchCubit(Map<String, dynamic> initialData)
    : super(ModifySearchState.initial(initialData));

  void updateFrom(String value) {
    emit(state.copyWith(from: value));
  }

  void updateTo(String value) {
    emit(state.copyWith(to: value));
  }

  void updateDepartureDate(String value) {
    emit(state.copyWith(departureDate: value));
  }

  void updateReturnDate(String value) {
    emit(state.copyWith(returnDate: value));
  }

  void updatePassengers(int adults, int children, int infants) {
    emit(state.copyWith(adults: adults, children: children, infants: infants));
  }

  void updateCabinClass(String cabinClass) {
    emit(state.copyWith(cabinClass: cabinClass));
  }

  void setHasReturnDate(bool hasReturnDate) {
    emit(state.copyWith(hasReturnDate: hasReturnDate));
  }

  void setShowDateError(bool showError) {
    emit(state.copyWith(showDateError: showError));
  }

  void swapFromTo() {
    final temp = state.from;
    emit(state.copyWith(from: state.to, to: temp));
  }

  void resetReturnDate() {
    emit(
      state.copyWith(
        hasReturnDate: false,
        returnDate: '',
        showDateError: false,
      ),
    );
  }
}
