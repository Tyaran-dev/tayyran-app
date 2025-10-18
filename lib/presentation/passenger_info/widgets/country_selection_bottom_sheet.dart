// lib/presentation/passenger_info/widgets/country_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/country_data.dart';
import 'package:easy_localization/easy_localization.dart';

class CountrySelectionBottomSheet extends StatefulWidget {
  final bool showNationality;

  const CountrySelectionBottomSheet({super.key, this.showNationality = false});

  @override
  State<CountrySelectionBottomSheet> createState() =>
      _CountrySelectionBottomSheetState();
}

class _CountrySelectionBottomSheetState
    extends State<CountrySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountryData.countries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = CountryData.countries
          .where(
            (country) =>
                country['name_en']!.toLowerCase().contains(query) ||
                country['name_ar']!.toLowerCase().contains(query) ||
                (widget.showNationality &&
                    country['nationality_en']!.toLowerCase().contains(query)) ||
                (widget.showNationality &&
                    country['nationality_ar']!.toLowerCase().contains(query)),
          )
          .toList();
    });
  }

  String _getLocalizedCountryName(Map<String, dynamic> country) {
    final locale = EasyLocalization.of(context)?.locale;
    if (locale?.languageCode == 'ar') {
      if (widget.showNationality) {
        return country['nationality_ar'] ??
            country['name_ar'] ??
            country['name_en'] ??
            '';
      }
      return country['name_ar'] ?? country['name_en'] ?? '';
    }
    if (widget.showNationality) {
      return country['nationality_en'] ?? country['name_en'] ?? '';
    }
    return country['name_en'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            widget.showNationality
                ? 'select_nationality'.tr()
                : 'select_country'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'search'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) => ListTile(
                leading: Text(
                  _filteredCountries[index]['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  _getLocalizedCountryName(_filteredCountries[index]),
                ),
                subtitle: widget.showNationality
                    ? Text(
                        _filteredCountries[index]['name_${context.locale.languageCode}']!,
                      )
                    : null,
                onTap: () => Navigator.pop(context, _filteredCountries[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
