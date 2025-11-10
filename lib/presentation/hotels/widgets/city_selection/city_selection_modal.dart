// lib/presentation/hotels/widgets/city_selection_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/data/models/city_model.dart';
import 'package:tayyran_app/presentation/hotels/widgets/city_selection/cubit/city_cubit.dart';

class CitySelectionModal extends StatefulWidget {
  final String countryCode;
  final Function(CityModel) onCitySelected;

  const CitySelectionModal({
    super.key,
    required this.countryCode,
    required this.onCitySelected,
  });

  @override
  State<CitySelectionModal> createState() => _CitySelectionModalState();
}

class _CitySelectionModalState extends State<CitySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<CityModel> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadCities() {
    context.read<CityCubit>().loadCities(widget.countryCode);
  }

  void _onSearchChanged() {
    final state = context.read<CityCubit>().state;
    if (state is CityLoaded) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCities = state.cities.where((city) {
          final displayName = city.name.toLowerCase();
          return displayName.contains(query) ||
              city.code.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'hotels.select_city'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'hotels.search_city'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cities List
          Expanded(
            child: BlocBuilder<CityCubit, CityState>(
              builder: (context, state) {
                if (state is CityLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('loading_cities'.tr()),
                      ],
                    ),
                  );
                }

                if (state is CityTranslating) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "loading_cities".tr(),
                        ), // Translating city names in Arabic
                      ],
                    ),
                  );
                }

                if (state is CityError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCities,
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CityLoaded) {
                  final citiesToShow = _searchController.text.isEmpty
                      ? state.cities
                      : _filteredCities;

                  if (citiesToShow.isEmpty) {
                    return Center(
                      child: Text(
                        'hotels.no_cities_found'.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: citiesToShow.length,
                    itemBuilder: (context, index) {
                      final city = citiesToShow[index];
                      final displayName = city.name.toLowerCase();

                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(displayName),
                        onTap: () {
                          widget.onCitySelected(city);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
