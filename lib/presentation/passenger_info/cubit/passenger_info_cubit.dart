// lib/presentation/passenger_info/cubit/passenger_info_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';

part 'passenger_info_state.dart';

class PassengerInfoCubit extends Cubit<PassengerInfoState> {
  final FlightOffer flightOffer;

  PassengerInfoCubit(this.flightOffer)
    : super(PassengerInfoState.initial(flightOffer));

  void updatePassengerFirstName(int index, String firstName) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      firstName: firstName,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerLastName(int index, String lastName) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      lastName: lastName,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerDateOfBirth(int index, String dateOfBirth) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      dateOfBirth: dateOfBirth,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerPassportNumber(int index, String passportNumber) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      passportNumber: passportNumber,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerPassportExpiry(int index, String passportExpiry) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      passportExpiry: passportExpiry,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerNationality(int index, String nationality) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      nationality: nationality,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  // void updatePassengerGender(int index, String gender) {
  //   final updatedPassengers = List<Passenger>.from(state.passengers);
  //   updatedPassengers[index] = updatedPassengers[index].copyWith(
  //     gender: gender,
  //   );
  //   emit(state.copyWith(passengers: updatedPassengers));
  // }

  // Add these methods to your PassengerInfoCubit
  void updatePassengerTitle(int index, String title) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(title: title);
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerIssuingCountry(int index, String issuingCountry) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      issuingCountry: issuingCountry,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updateContactEmail(String email) {
    emit(state.copyWith(contactEmail: email));
  }

  void updateContactPhone(String phone) {
    emit(state.copyWith(contactPhone: phone));
  }

  void submitPassengerInfo() {
    if (!state.isFormValid) return;

    emit(state.copyWith(isSubmitting: true));

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
      // Navigate to payment screen
    });
  }
}
