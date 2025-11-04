// lib/presentation/passenger_info/widgets/country_code_selection_bottom_sheet.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/country_data.dart';

class CountryCodeSelectionBottomSheet extends StatefulWidget {
  const CountryCodeSelectionBottomSheet({super.key});

  @override
  State<CountryCodeSelectionBottomSheet> createState() =>
      _CountryCodeSelectionBottomSheetState();
}

class _CountryCodeSelectionBottomSheetState
    extends State<CountryCodeSelectionBottomSheet> {
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
                country['dial_code']!.contains(query) ||
                country['name_ar']!.toLowerCase().contains(query) ||
                country['code']!.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'selectCountryCode'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'searchCountryOrCode'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Country code list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Text(
                    _filteredCountries[index]['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: isArabic
                      ? Text(_filteredCountries[index]['name_ar']!)
                      : Text(_filteredCountries[index]['name_en']!),
                  trailing: Text(_filteredCountries[index]['dial_code']!),
                  onTap: () =>
                      Navigator.pop(context, _filteredCountries[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
