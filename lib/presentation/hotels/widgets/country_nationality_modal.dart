import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/country_data.dart';

class CountryNationalityModal extends StatefulWidget {
  final Function(String, String)
  onSelected; // Returns display text and country code
  final bool isForNationality;

  const CountryNationalityModal({
    super.key,
    required this.onSelected,
    this.isForNationality = false,
  });

  @override
  State<CountryNationalityModal> createState() =>
      _CountryNationalityModalState();
}

class _CountryNationalityModalState extends State<CountryNationalityModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCountries = [];
  List<Map<String, dynamic>> _allCountries = [];

  @override
  void initState() {
    super.initState();
    // Use all 248 countries for country selection, 194 sovereign states for nationality
    // _allCountries = widget.isForNationality
    //     ? CountryData.countries.take(194).toList()
    //     : [...CountryData.countries, ...CountryData.territories];
    _allCountries = [...CountryData.countries, ...CountryData.territories];
    debugPrint("${_allCountries.length}");
    _filteredCountries = _allCountries;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((country) {
          final nameEn = country['name_en']?.toString().toLowerCase() ?? '';
          final nameAr = country['name_ar']?.toString().toLowerCase() ?? '';

          if (widget.isForNationality) {
            // For nationality: search in both country names and nationalities
            final nationalityEn =
                country['nationality_en']?.toString().toLowerCase() ?? '';
            final nationalityAr =
                country['nationality_ar']?.toString().toLowerCase() ?? '';

            return nameEn.contains(query) ||
                nameAr.contains(query) ||
                nationalityEn.contains(query) ||
                nationalityAr.contains(query);
          } else {
            // For country: search only in country names
            return nameEn.contains(query) || nameAr.contains(query);
          }
        }).toList();
      }
    });
  }

  String _getCountryName(Map<String, dynamic> country) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? country['name_ar'] : country['name_en'];
  }

  String _getNationality(Map<String, dynamic> country) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? country['nationality_ar'] : country['nationality_en'];
  }

  String _getDisplayText(Map<String, dynamic> country) {
    return widget.isForNationality
        ? _getNationality(country)
        : _getCountryName(country);
  }

  String _getSearchHint() {
    return widget.isForNationality
        ? 'hotels.search_nationality'.tr()
        : 'hotels.search_country'.tr();
  }

  String _getTitle() {
    return widget.isForNationality
        ? 'hotels.select_nationality'.tr()
        : 'hotels.select_country'.tr();
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _getSearchHint(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.splashBackgroundColorEnd,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Countries/Nationalities List
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_results_found'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      return _buildListItem(country);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> country) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            country['flag'] ?? '🏳️',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: widget.isForNationality
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCountryName(country),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getNationality(country),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            )
          : Text(
              _getCountryName(country),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
      onTap: () {
        final displayText = _getDisplayText(country);
        final countryCode = country['code'] ?? '';
        widget.onSelected(displayText, countryCode);
      },
    );
  }
}
