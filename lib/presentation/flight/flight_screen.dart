// flight_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/home/widgets/index.dart';

class FlightScreen extends StatelessWidget {
  const FlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlightCubit(),
      child: const FlightScreenContent(),
    );
  }
}

class FlightScreenContent extends StatelessWidget {
  const FlightScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlightCubit, FlightState>(
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
                          SearchFormWidget(),
                          // Recent Searches Section
                          if (state.recentSearches.isNotEmpty &&
                              state.tripType != "multi") ...[
                            const SizedBox(height: 24),
                            _buildRecentSearchesHeader(context, state),
                            const SizedBox(height: 12),
                            _buildRecentSearchesList(context, state),
                            const SizedBox(height: 20),
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

  Widget _buildRecentSearchesHeader(BuildContext context, FlightState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "recent_searches".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          GestureDetector(
            onTap: () => context.read<FlightCubit>().clearAllRecentSearches(),
            child: Text(
              "clear_all".tr(),
              style: TextStyle(color: Color(0xFFFF7300), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesList(BuildContext context, FlightState state) {
    return Column(
      children: state.recentSearches.map((search) {
        final index = state.recentSearches.indexOf(search);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: RecentSearchCard(
            ticket: search,
            onTap: () {
              context.read<FlightCubit>().prefillFromRecentSearch(
                search,
                context,
              );
            },
            onDelete: () {
              context.read<FlightCubit>().removeRecentSearch(index);
            },
          ),
        );
      }).toList(),
    );
  }
}
