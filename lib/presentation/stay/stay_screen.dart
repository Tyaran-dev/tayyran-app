// stay_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/home/widgets/recent_search_card.dart';
import 'package:tayyran_app/presentation/stay/cubit/stay_cubit.dart';

class StayScreen extends StatelessWidget {
  const StayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StayCubit(),
      child: const StayScreenContent(),
    );
  }
}

class StayScreenContent extends StatelessWidget {
  const StayScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StayCubit, StayState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStayForm(context, state),
                          const SizedBox(height: 20),

                          // Search Button
                          Center(
                            child: state.isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.splashBackgroundColorEnd,
                                    ),
                                  )
                                : GradientButton(
                                    text: 'Search Stays',
                                    height: 45,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.90,
                                    onPressed: () {
                                      // Validate fields first
                                      if (state.to.isEmpty ||
                                          state.checkInDate.isEmpty ||
                                          state.checkOutDate.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please fill all required fields",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      context.read<StayCubit>().search();
                                    },
                                  ),
                          ),

                          // Recent Searches Section
                          if (state.recentSearches.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildRecentSearchesHeader(context, state),
                            const SizedBox(height: 12),
                            _buildRecentSearchesList(context, state),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStayForm(BuildContext context, StayState state) {
    final cubit = context.read<StayCubit>();

    return Column(
      children: [
        _buildTextField(
          "Destination",
          state.to,
          Icons.location_city,
          context,
          cubit,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                "Check-in",
                state.checkInDate,
                Icons.calendar_today,
                () => _selectDate(context, cubit, isCheckIn: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                "Check-out",
                state.checkOutDate,
                Icons.calendar_today,
                () => _selectDate(context, cubit, isCheckIn: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRoomsAndGuestsField(state, cubit, context),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    IconData icon,
    BuildContext context,
    StayCubit cubit,
  ) {
    return GestureDetector(
      onTap: () {
        _showDestinationBottomSheet(context, cubit);
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            floatingLabelStyle: value.isEmpty
                ? const TextStyle(color: Colors.deepPurple)
                : const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    StayCubit cubit, {
    required bool isCheckIn,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

    if (picked != null) {
      final monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      final formattedDate =
          "${picked.day}-${monthNames[picked.month - 1]}-${picked.year}";

      if (isCheckIn) {
        cubit.setCheckInDate(formattedDate);
      } else {
        cubit.setCheckOutDate(formattedDate);
      }
    }
  }

  Widget _buildRoomsAndGuestsField(
    StayState state,
    StayCubit cubit,
    BuildContext context,
  ) {
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
              initialChildSize: 0.5,
              minChildSize: 0.4,
              maxChildSize: 0.7,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Rooms & Guests",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rooms Selection
                    _buildCounterRow(
                      "Number of Rooms",
                      state.rooms,
                      (value) => cubit.setRoomsAndGuests(value, state.guests),
                      1,
                      10,
                    ),

                    const SizedBox(height: 20),

                    // Guests Selection
                    _buildCounterRow(
                      "Number of Guests",
                      state.guests,
                      (value) => cubit.setRoomsAndGuests(state.rooms, value),
                      1,
                      20,
                    ),

                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Apply"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
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
                    "${state.rooms} Room${state.rooms != 1 ? 's' : ''}, ${state.guests} Guest${state.guests != 1 ? 's' : ''}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${state.rooms} Room${state.rooms != 1 ? 's' : ''}, ${state.guests} Adult${state.guests != 1 ? 's' : ''}",
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

  Widget _buildCounterRow(
    String title,
    int value,
    Function(int) onChanged,
    int min,
    int max,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, size: 28),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                "$value",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, size: 28),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  void _showDestinationBottomSheet(BuildContext context, StayCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Destination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDestinationItem(
                        'Dubai, UAE',
                        Icons.location_city,
                        cubit,
                        context, // Pass context here
                      ),
                      _buildDestinationItem(
                        'Abu Dhabi, UAE',
                        Icons.location_city,
                        cubit,
                        context, // Pass context here
                      ),
                      _buildDestinationItem(
                        'Sharjah, UAE',
                        Icons.location_city,
                        cubit,
                        context, // Pass context here
                      ),
                      _buildDestinationItem(
                        'Burj Al Arab',
                        Icons.hotel,
                        cubit,
                        context, // Pass context here
                      ),
                      _buildDestinationItem(
                        'Atlantis The Palm',
                        Icons.hotel,
                        cubit,
                        context, // Pass context here
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationItem(
    String destination,
    IconData icon,
    StayCubit cubit,
    BuildContext context, // Add context parameter
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(destination),
      onTap: () {
        cubit.setDestination(destination);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildRecentSearchesHeader(BuildContext context, StayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Searches",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          GestureDetector(
            onTap: () {
              context.read<StayCubit>().clearAllRecentSearches();
            },
            child: const Text(
              "Clear All",
              style: TextStyle(color: Color(0xFFFF7300), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesList(BuildContext context, StayState state) {
    return Column(
      children: state.recentSearches.map((search) {
        final index = state.recentSearches.indexOf(search);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: RecentSearchCard(
            ticket: search,
            onTap: () {
              context.read<StayCubit>().prefillFromRecentSearch(search);
            },
            onDelete: () {
              context.read<StayCubit>().removeRecentSearch(index);
            },
          ),
        );
      }).toList(),
    );
  }
}
