import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/hotels/cubit/hotel_cubit.dart';
import 'package:tayyran_app/presentation/hotels/cubit/hotel_state.dart';
import 'package:tayyran_app/presentation/hotels/widgets/city_selection/city_selection_modal.dart';
import 'package:tayyran_app/presentation/hotels/widgets/city_selection/cubit/city_cubit.dart';
import 'package:tayyran_app/presentation/hotels/widgets/country_nationality_modal.dart';
import 'package:tayyran_app/presentation/hotels/widgets/room_selection_modal.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HotelCubit(),
      child: const HotelsScreenContent(),
    );
  }
}

class HotelsScreenContent extends StatelessWidget {
  const HotelsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),

              // Search Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SearchFormWidget(),
                      const SizedBox(height: 20),

                      // Recent Searches (you can add this later)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchFormWidget extends StatefulWidget {
  const SearchFormWidget({super.key});

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  bool _showDateError = false;
  final GlobalKey _checkOutDateKey = GlobalKey();

  void _validateDates(HotelState state) {
    if (state.checkInDate.isNotEmpty && state.checkOutDate.isNotEmpty) {
      final checkIn = parseDate(state.checkInDate);
      final checkOut = parseDate(state.checkOutDate);

      if (mounted) {
        setState(() {
          _showDateError = checkOut.isBefore(
            checkIn.add(const Duration(days: 1)),
          );
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _showDateError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelCubit, HotelState>(
      builder: (context, state) {
        // Validate dates when state changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _validateDates(state);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelForm(state, context),
            const SizedBox(height: 20),
            Center(
              child: state.isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.splashBackgroundColorEnd,
                      ),
                    )
                  : GradientButton(
                      text: 'hotels.search_hotels'.tr(),
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.90,
                      onPressed: () {
                        _validateAndSearch(context, state);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _validateAndSearch(BuildContext context, HotelState state) {
    final cubit = context.read<HotelCubit>();

    if (state.country.isEmpty ||
        state.city.isEmpty ||
        state.checkInDate.isEmpty ||
        state.checkOutDate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("fill_required_fields".tr())));
      return;
    }

    if (state.checkInDate.isNotEmpty && state.checkOutDate.isNotEmpty) {
      final checkIn = parseDate(state.checkInDate);
      final checkOut = parseDate(state.checkOutDate);

      if (checkOut.isBefore(checkIn.add(const Duration(days: 1)))) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("checkout_date_error".tr())));
        return;
      }
    }

    cubit.searchHotels(context);
  }

  Widget _buildHotelForm(HotelState state, BuildContext context) {
    return Column(
      children: [
        // Country Field
        _buildCountryField(state, context),
        const SizedBox(height: 12),

        // City Field
        _buildCityField(state, context),
        const SizedBox(height: 12),

        // Check-in & Check-out Dates
        Row(
          children: [
            Expanded(
              child: DateTextField(
                label: "hotels.check_in".tr(),
                value: state.checkInDate,
                icon: Icons.calendar_today,
                onTap: () => _selectDate(context, isCheckIn: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                key: _checkOutDateKey,
                children: [
                  DateTextField(
                    label: "hotels.check_out".tr(),
                    value: state.checkOutDate,
                    icon: Icons.calendar_today,
                    onTap: () => _selectDate(context, isCheckIn: false),
                    hasError: _showDateError,
                  ),
                  if (_showDateError)
                    Positioned(
                      right: isRTL(context) ? null : 8,
                      left: isRTL(context) ? 8 : null,
                      top: 8,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        if (_showDateError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "hotels.checkout_date_error".tr(),
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),

        const SizedBox(height: 12),

        // Nationality Field
        _buildNationalityField(state, context),
        const SizedBox(height: 12),

        // Rooms & Guests Field
        _buildRoomsField(state, context),
      ],
    );
  }

  Widget _buildCountryField(HotelState state, BuildContext context) {
    final cubit = context.read<HotelCubit>();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => CountryNationalityModal(
                isForNationality: false, // Nationality selection
                onSelected: (country, countryCode) {
                  cubit.setCountry(country, countryCode);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.flag, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.country.isEmpty
                        ? "hotels.select_country".tr()
                        : state.country,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: state.country.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField(HotelState state, BuildContext context) {
    final cubit = context.read<HotelCubit>();

    return GestureDetector(
      onTap: state.country.isEmpty
          ? null
          : () {
              // Create a BlocProvider for the CityCubit
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => BlocProvider(
                  create: (_) => getIt<CityCubit>(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.6,
                      maxChildSize: 0.9,
                      builder: (_, controller) => CitySelectionModal(
                        countryCode: state.countryCode,
                        onCitySelected: (city) {
                          cubit.setCity(city);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: state.country.isEmpty
                ? Colors.grey.shade300
                : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(12),
          color: state.country.isEmpty ? Colors.grey.shade100 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_city,
              color: state.country.isEmpty
                  ? Colors.grey.shade400
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.city.isEmpty ? "hotels.select_city".tr() : state.city,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: state.city.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                  if (state.country.isEmpty)
                    Text(
                      "hotels.select_country_first".tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: state.country.isEmpty
                  ? Colors.grey.shade400
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildCityField(HotelState state, BuildContext context) {
  //   final cubit = context.read<HotelCubit>();

  //   return GestureDetector(
  //     onTap: state.country.isEmpty
  //         ? null
  //         : () {
  //             showModalBottomSheet(
  //               context: context,
  //               isScrollControlled: true,
  //               backgroundColor: Colors.transparent,
  //               builder: (context) => Padding(
  //                 padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom,
  //                 ),
  //                 child: DraggableScrollableSheet(
  //                   initialChildSize: 0.8,
  //                   minChildSize: 0.6,
  //                   maxChildSize: 0.9,
  //                   builder: (_, controller) => CitySelectionModal(
  //                     countryCode: state.countryCode,
  //                     onCitySelected: (city) {
  //                       cubit.setCity(city);
  //                       Navigator.pop(context);
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: state.country.isEmpty
  //               ? Colors.grey.shade300
  //               : Colors.grey.shade400,
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //         color: state.country.isEmpty ? Colors.grey.shade100 : Colors.white,
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             Icons.location_city,
  //             color: state.country.isEmpty
  //                 ? Colors.grey.shade400
  //                 : Colors.grey[600],
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   state.city.isEmpty ? "hotels.select_city".tr() : state.city,
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w500,
  //                     color: state.city.isEmpty ? Colors.grey : Colors.black,
  //                   ),
  //                 ),
  //                 if (state.country.isEmpty)
  //                   Text(
  //                     "hotels.select_country_first".tr(),
  //                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //                   ),
  //               ],
  //             ),
  //           ),
  //           Icon(
  //             Icons.arrow_drop_down,
  //             color: state.country.isEmpty
  //                 ? Colors.grey.shade400
  //                 : Colors.grey[600],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNationalityField(HotelState state, BuildContext context) {
    final cubit = context.read<HotelCubit>();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => CountryNationalityModal(
                isForNationality: true,
                onSelected: (nationality, countryCode) {
                  cubit.setNationality(nationality, countryCode);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.nationality.isEmpty
                        ? "hotels.select_nationality".tr()
                        : state.nationality,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: state.nationality.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  if (state.nationality.isEmpty)
                    Text(
                      "hotels.default_country_will_be_used".tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsField(HotelState state, BuildContext context) {
    final cubit = context.read<HotelCubit>();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => RoomSelectionModal(
                rooms: state.rooms,
                onRoomsChanged: (rooms) => cubit.setRooms(rooms),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.hotel, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${state.totalRooms} ${'hotels.rooms'.tr()} • ${state.totalAdults} ${'hotels.adults'.tr()} • ${state.totalChildren} ${'hotels.children'.tr()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isCheckIn,
  }) async {
    final cubit = context.read<HotelCubit>();
    final state = cubit.state;

    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    if (isCheckIn && state.checkInDate.isNotEmpty) {
      initialDate = parseDate(state.checkInDate);
    } else if (!isCheckIn && state.checkOutDate.isNotEmpty) {
      initialDate = parseDate(state.checkOutDate);
      if (state.checkInDate.isNotEmpty) {
        final checkInDate = parseDate(state.checkInDate);
        firstDate = checkInDate.add(const Duration(days: 1));
        if (initialDate.isBefore(firstDate)) {
          initialDate = firstDate;
        }
      }
    }

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.splashBackgroundColorEnd,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.splashBackgroundColorEnd,
              ),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Format as YYYY-MM-DD for backend
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      print('📅 Hotel date selected:');
      print('   Date (YYYY-MM-DD): $formattedDate');
      print('   Is Check-in: $isCheckIn');

      if (isCheckIn) {
        cubit.setCheckInDate(formattedDate);
        // Auto-set checkout date to next day
        if (state.checkOutDate.isEmpty) {
          final nextDay = picked.add(const Duration(days: 1));
          final nextDayFormatted =
              "${nextDay.year}-${nextDay.month.toString().padLeft(2, '0')}-${nextDay.day.toString().padLeft(2, '0')}";
          cubit.setCheckOutDate(nextDayFormatted);

          print('🔄 Auto-set checkout date:');
          print('   Date: $nextDayFormatted');
        }
      } else {
        cubit.setCheckOutDate(formattedDate);
      }
    }
  }
}
