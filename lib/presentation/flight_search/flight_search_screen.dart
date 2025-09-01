// flight_search_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/filter_bottom_sheet.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/flight_ticket_card.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/filter_sort_chip_bar.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/modify_search_sheet.dart';

class FlightSearchScreen extends StatelessWidget {
  final Map<String, dynamic> searchData;

  const FlightSearchScreen({super.key, required this.searchData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlightSearchCubit()..loadFlights(searchData),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          height: 120,
          title: 'Flight Results',
          showBackButton: true,
          isFlightResults: true,
          searchData: searchData,
          onDestinationTap: () {
            final cubit = context.read<FlightSearchCubit>();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) =>
                  ModifySearchSheet(initialData: searchData, cubit: cubit),
            );
          },
        ),
        body: BlocBuilder<FlightSearchCubit, FlightSearchState>(
          builder: (context, state) {
            print(
              'FlightSearchScreen rebuilding with state: ${state.searchData}',
            ); // Add this

            return _buildContentArea(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, FlightSearchState state) {
    final cubit = context.read<FlightSearchCubit>();

    return Column(
      children: [
        // Filter & Sort Chip Bar
        FilterSortChipBar(
          selectedSorts: state.selectedSorts,
          filters: state.filters,
          onSortChanged: (sorts) => cubit.applySorts(sorts),
          onFilterPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => FilterBottomSheet(
                currentFilters: state.filters,
                onApplyFilters: (filters) {
                  cubit.applyFilters(filters);
                },
              ),
            );
          },
          onSortRemoved: (sort) {
            final newSorts = Set<SortOption>.from(state.selectedSorts);
            newSorts.remove(sort);
            cubit.applySorts(newSorts);
          },
          onFilterRemoved: (filterType, value) {
            cubit.removeFilter(filterType, value);
          },
        ),

        // Results count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.filteredTickets.length} flights found',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Results or Loading/Error
        Expanded(child: _buildResults(context, state)),
      ],
    );
  }

  Widget _buildResults(BuildContext context, FlightSearchState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.splashBackgroundColorEnd,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching for flights...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<FlightSearchCubit>().loadFlights(state.searchData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.splashBackgroundColorEnd,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.filteredTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No flights found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try modifying your search criteria',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredTickets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FlightTicketCard(ticket: state.filteredTickets[index]),
        );
      },
    );
  }
}
