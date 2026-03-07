import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/address.dart';
import '../providers/user_profile_provider.dart';
import '../services/address_service.dart';
import '../widgets/gradient_scaffold.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  static const String routeName = '/addresses';
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...profile.addresses.asMap().entries.map((entry) {
              final i = entry.key;
              final addr = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white.withValues(alpha: 0.15),
                child: ListTile(
                  title: Text(
                    addr.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${addr.fullAddress}, ${addr.city}${addr.postalCode != null ? ' ${addr.postalCode}' : ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showAddressForm(
                          context,
                          profile: profile,
                          index: i,
                          existing: addr,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white70,
                        ),
                        onPressed: () => profile.removeAddress(i),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddressForm(context, profile: profile),
              icon: const Icon(Icons.add),
              label: const Text('Add address'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAddressForm(
    BuildContext context, {
    required UserProfileProvider profile,
    int? index,
    Address? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final labelController = TextEditingController(
          text: existing?.label ?? '',
        );
        final streetController = TextEditingController(
          text: existing?.street ?? '',
        );
        final postalController = TextEditingController(
          text: existing?.postalCode ?? '',
        );
        final addressService = const AddressService();
        List<Region> regions = [];
        List<Province> provinces = [];
        List<CityMunicipality> cities = [];
        List<Barangay> barangays = [];
        String? selectedRegionCode = existing?.region;
        String? selectedProvinceCode = existing?.province;
        String? selectedCityCode = existing?.cityOrMunicipality;
        String? selectedBarangayCode = existing?.barangay;
        bool isDefault = existing?.isDefault ?? profile.addresses.isEmpty;
        Future<void> loadRegions(StateSetter setState) async {
          final data = await addressService.getRegions();
          setState(() {
            regions = data;
          });
        }

        Future<void> loadProvinces(
          StateSetter setState,
          String regionCode, {
          String? preselect,
        }) async {
          final data = await addressService.getProvinces(regionCode);
          setState(() {
            provinces = data;
            selectedProvinceCode = preselect;
          });
        }

        Future<void> loadCities(
          StateSetter setState,
          String provinceCode, {
          String? preselect,
        }) async {
          final data = await addressService.getCities(provinceCode);
          setState(() {
            cities = data;
            selectedCityCode = preselect;
          });
        }

        Future<void> loadBarangays(
          StateSetter setState,
          String cityCode, {
          String? preselect,
        }) async {
          final data = await addressService.getBarangays(cityCode);
          setState(() {
            barangays = data;
            selectedBarangayCode = preselect;
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            if (regions.isEmpty) {
              loadRegions(setState);
            }
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null ? 'Add address' : 'Edit address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label (e.g. Home, Office)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRegionCode,
                      decoration: const InputDecoration(labelText: 'Region'),
                      items: regions
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.code,
                              child: Text(r.name),
                            ),
                          )
                          .toList(),
                      onChanged: (code) {
                        setState(() {
                          selectedRegionCode = code;
                          selectedProvinceCode = null;
                          selectedCityCode = null;
                          selectedBarangayCode = null;
                          provinces = [];
                          cities = [];
                          barangays = [];
                        });
                        if (code != null) {
                          loadProvinces(setState, code);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProvinceCode,
                      decoration: const InputDecoration(labelText: 'Province'),
                      items: provinces
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.code,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (code) {
                        setState(() {
                          selectedProvinceCode = code;
                          selectedCityCode = null;
                          selectedBarangayCode = null;
                          cities = [];
                          barangays = [];
                        });
                        if (code != null) {
                          loadCities(setState, code);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCityCode,
                      decoration: const InputDecoration(
                        labelText: 'City / Municipality',
                      ),
                      items: cities
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.code,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (code) {
                        setState(() {
                          selectedCityCode = code;
                          selectedBarangayCode = null;
                          barangays = [];
                        });
                        if (code != null) {
                          loadBarangays(setState, code);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBarangayCode,
                      decoration: const InputDecoration(labelText: 'Barangay'),
                      items: barangays
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.code,
                              child: Text(b.name),
                            ),
                          )
                          .toList(),
                      onChanged: (code) {
                        setState(() {
                          selectedBarangayCode = code;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street / House / Building',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: postalController,
                      decoration: const InputDecoration(
                        labelText: 'Postal code',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value;
                        });
                      },
                      title: const Text('Set as default address'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        final label = labelController.text.trim();
                        final street = streetController.text.trim();
                        final postal = postalController.text.trim();
                        if (label.isEmpty ||
                            street.isEmpty ||
                            selectedRegionCode == null ||
                            selectedProvinceCode == null ||
                            selectedCityCode == null ||
                            selectedBarangayCode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill label, address, region, province, city, and barangay',
                              ),
                            ),
                          );
                          return;
                        }
                        final id =
                            existing?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString();
                        final regionName = regions
                            .firstWhere(
                              (r) => r.code == selectedRegionCode,
                              orElse: () => const Region(code: '', name: ''),
                            )
                            .name;
                        final provinceName = provinces
                            .firstWhere(
                              (p) => p.code == selectedProvinceCode,
                              orElse: () => const Province(
                                code: '',
                                name: '',
                                regionCode: '',
                              ),
                            )
                            .name;
                        final cityName = cities
                            .firstWhere(
                              (c) => c.code == selectedCityCode,
                              orElse: () => const CityMunicipality(
                                code: '',
                                name: '',
                                provinceCode: '',
                              ),
                            )
                            .name;
                        final barangayName = barangays
                            .firstWhere(
                              (b) => b.code == selectedBarangayCode,
                              orElse: () => const Barangay(
                                code: '',
                                name: '',
                                cityCode: '',
                              ),
                            )
                            .name;
                        final displayFullAddress =
                            '$street, $barangayName, $cityName, $provinceName';
                        final addr = Address(
                          id: id,
                          label: label,
                          fullAddress: displayFullAddress,
                          city: cityName,
                          postalCode: postal.isEmpty ? null : postal,
                          isDefault: isDefault || profile.addresses.isEmpty,
                          region: regionName,
                          province: provinceName,
                          cityOrMunicipality: cityName,
                          barangay: barangayName,
                          street: street,
                        );
                        if (index != null) {
                          await profile.updateAddress(index, addr);
                        } else {
                          await profile.addAddress(addr);
                        }
                        if (isDefault || profile.addresses.length == 1) {
                          await profile.setDefaultAddress(id);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
