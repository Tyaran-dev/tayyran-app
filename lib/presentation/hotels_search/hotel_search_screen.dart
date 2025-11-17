// lib/presentation/hotels/screens/hotel_search_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/loading_shimmer.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/presentation/hotel_details/hotel_details_screen.dart';
import 'package:tayyran_app/presentation/hotels_search/cubit/hotel_search_cubit.dart';
import 'package:tayyran_app/presentation/hotels_search/widgets/hotel_card.dart';

class HotelSearchScreen extends StatefulWidget {
  final Map<String, dynamic> searchParams;

  const HotelSearchScreen({super.key, required this.searchParams});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchResultsPageState();
}

class _HotelSearchResultsPageState extends State<HotelSearchScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger search when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelSearchCubit>().searchHotels(widget.searchParams);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        height: 120,
        showBackButton: true,
        title: 'hotels.search_results'.tr(),
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<HotelSearchCubit, HotelSearchState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Summary
                _buildSearchSummary(context, state),
                const SizedBox(height: 16),

                // Results
                Expanded(child: _buildResultsContent(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context, HotelSearchState state) {
    int hotelCount = 0;
    if (state is HotelSearchLoaded) {
      hotelCount = state.hotels.length;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'hotels.found_hotels'.tr()} • $hotelCount',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(HotelSearchState state) {
    if (state is HotelSearchLoading) {
      return _buildLoadingShimmer();
    } else if (state is HotelSearchError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state.error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<HotelSearchCubit>().searchHotels(
                  widget.searchParams,
                );
              },
              child: Text('hotels.retry'.tr()),
            ),
          ],
        ),
      );
    } else if (state is HotelSearchLoaded) {
      if (state.hotels.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'hotels.no_hotels_found'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: state.hotels.length,
        itemBuilder: (context, index) {
          final hotel = state.hotels[index];
          return HotelCard(
            hotel: hotel,
            onTap: () {
              // Navigate to hotel details - we'll implement this later
              _showHotelDetails(context, hotel);
            },
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: LoadingShimmer.hotelCard(),
        );
      },
    );
  }

  void _showHotelDetails(BuildContext context, HotelData hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HotelDetailsScreen(hotel: hotel, searchParams: widget.searchParams),
      ),
    );
  }
}
