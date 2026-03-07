import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/address.dart';

class Region {
  const Region({required this.code, required this.name});

  final String code;
  final String name;
}

class Province {
  const Province({
    required this.code,
    required this.name,
    required this.regionCode,
  });

  final String code;
  final String name;
  final String regionCode;
}

class CityMunicipality {
  const CityMunicipality({
    required this.code,
    required this.name,
    required this.provinceCode,
  });

  final String code;
  final String name;
  final String provinceCode;
}

class Barangay {
  const Barangay({
    required this.code,
    required this.name,
    required this.cityCode,
  });

  final String code;
  final String name;
  final String cityCode;
}

class AddressService {
  const AddressService();

  static Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _loadData() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(
      'assets/data/catanduanes_addresses.json',
    );
    _cache = jsonDecode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  Future<List<Region>> getRegions() async {
    final data = await _loadData();
    final region = data['region'] as Map<String, dynamic>;
    return [
      Region(code: region['code'] as String, name: region['name'] as String),
    ];
  }

  Future<List<Province>> getProvinces(String regionCode) async {
    final data = await _loadData();
    final province = data['province'] as Map<String, dynamic>;
    if (province['regionCode'] != regionCode) return const [];
    return [
      Province(
        code: province['code'] as String,
        name: province['name'] as String,
        regionCode: province['regionCode'] as String,
      ),
    ];
  }

  Future<List<CityMunicipality>> getCities(String provinceCode) async {
    final data = await _loadData();
    final province = data['province'] as Map<String, dynamic>;
    if (province['code'] != provinceCode) return const [];
    final cities = data['cities'] as List<dynamic>;
    return cities
        .map(
          (c) => CityMunicipality(
            code: c['code'] as String,
            name: c['name'] as String,
            provinceCode: provinceCode,
          ),
        )
        .toList();
  }

  Future<List<Barangay>> getBarangays(String cityCode) async {
    final data = await _loadData();
    final cities = data['cities'] as List<dynamic>;
    final city = cities.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['code'] == cityCode,
      orElse: () => <String, dynamic>{},
    );
    if (city.isEmpty) return const [];
    final brgys = city['barangays'] as List<dynamic>;
    return brgys
        .map(
          (name) => Barangay(
            code: '${cityCode}_$name',
            name: name as String,
            cityCode: cityCode,
          ),
        )
        .toList();
  }

  // Helper to build a display address string from structured fields.
  String formattedAddressFromStructured(Address address) {
    final parts = <String>[];
    if (address.street != null && address.street!.trim().isNotEmpty) {
      parts.add(address.street!.trim());
    }
    if (address.barangay != null && address.barangay!.trim().isNotEmpty) {
      parts.add(address.barangay!.trim());
    }
    if (address.cityOrMunicipality != null &&
        address.cityOrMunicipality!.trim().isNotEmpty) {
      parts.add(address.cityOrMunicipality!.trim());
    }
    if (address.province != null && address.province!.trim().isNotEmpty) {
      parts.add(address.province!.trim());
    }
    if (address.region != null && address.region!.trim().isNotEmpty) {
      parts.add(address.region!.trim());
    }
    return parts.join(', ');
  }
}
