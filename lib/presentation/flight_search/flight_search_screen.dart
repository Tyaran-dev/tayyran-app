import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';

class FlightSearchScreen extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  final String returnDate;
  final int passengers;
  final String cabinClass;
  final String tripType;

  const FlightSearchScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.returnDate,
    required this.passengers,
    required this.cabinClass,
    required this.tripType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlightSearchCubit(
        from: from,
        to: to,
        date: date,
        returnDate: returnDate,
        passengers: passengers,
        cabinClass: cabinClass,
        tripType: tripType,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flight Results'),
          backgroundColor: AppColors.splashBackgroundColorEnd,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<FlightSearchCubit, FlightSearchState>(
          builder: (context, state) {
            final cubit = context.read<FlightSearchCubit>();

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: cubit.retrySearch,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Search summary header
                _buildSearchSummary(),

                // Sort options
                _buildSortOptions(cubit, state),

                // Results list
                Expanded(
                  child: ListView.builder(
                    itemCount: state.flights.length,
                    itemBuilder: (context, index) {
                      return _buildFlightCard(state.flights[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${from.split(" - ")[0]} → ${to.split(" - ")[0]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '$date • $passengers passenger${passengers > 1 ? "s" : ""} • $cabinClass',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (tripType == "round")
                Text(
                  'Return: $returnDate',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(FlightSearchCubit cubit, FlightSearchState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _buildSortButton(
            'Price',
            state.sortBy == 'price',
            () => cubit.sortByPrice(),
          ),
          const SizedBox(width: 8),
          _buildSortButton(
            'Duration',
            state.sortBy == 'duration',
            () => cubit.sortByDuration(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(
    String text,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.splashBackgroundColorEnd
            : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }

  Widget _buildFlightCard(FlightTicket flight) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  flight.departureTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.airplanemode_active, color: Colors.blue),
                Text(
                  flight.arrivalTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  flight.departureAirport,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  flight.duration,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  flight.arrivalAirport,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${flight.stops} stop${flight.stops != 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '\$${flight.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.splashBackgroundColorEnd,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Select Flight'),
            ),
          ],
        ),
      ),
    );
  }
}
