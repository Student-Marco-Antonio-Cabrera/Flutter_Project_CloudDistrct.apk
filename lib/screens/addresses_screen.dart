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
                    '${addr.fullAddress}, ${addr.city}'
                    '${addr.postalCode != null ? ' ${addr.postalCode}' : ''}',
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
      // ── KEY FIX: use a proper StatefulWidget so keyboard toggles
      //    don't reset dropdown state ──────────────────────────────
      builder: (context) => _AddressFormSheet(
        profile: profile,
        index: index,
        existing: existing,
      ),
    );
  }
}

// ── Address form as its own StatefulWidget ────────────────────────────────────
// This ensures controllers and dropdown selections survive keyboard show/hide.

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({
    required this.profile,
    this.index,
    this.existing,
  });

  final UserProfileProvider profile;
  final int? index;
  final Address? existing;

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  // ── Text controllers (survive rebuilds) ──────────────────────────
  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalController;

  // ── Address service & dropdown data ──────────────────────────────
  final _addressService = const AddressService();
  List<Region> _regions = [];
  List<Province> _provinces = [];
  List<CityMunicipality> _cities = [];
  List<Barangay> _barangays = [];

  // ── Selected codes ────────────────────────────────────────────────
  String? _selectedRegionCode;
  String? _selectedProvinceCode;
  String? _selectedCityCode;
  String? _selectedBarangayCode;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController  = TextEditingController(text: existing?.label ?? '');
    _streetController = TextEditingController(text: existing?.street ?? '');
    _postalController = TextEditingController(text: existing?.postalCode ?? '');
    _isDefault = existing?.isDefault ?? widget.profile.addresses.isEmpty;

    // Pre-load regions; then cascade-load selections for edit mode.
    _loadRegions(preselectExisting: existing != null);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  // ── Data loaders ──────────────────────────────────────────────────

  Future<void> _loadRegions({bool preselectExisting = false}) async {
    final data = await _addressService.getRegions();
    if (!mounted) return;
    setState(() => _regions = data);

    if (preselectExisting && widget.existing?.region != null) {
      // Find region by name (stored as name, not code)
      final match = _regions.cast<Region?>().firstWhere(
        (r) => r?.name == widget.existing!.region,
        orElse: () => null,
      );
      if (match != null) {
        setState(() => _selectedRegionCode = match.code);
        await _loadProvinces(match.code, preselectExisting: true);
      }
    }
  }

  Future<void> _loadProvinces(String regionCode,
      {bool preselectExisting = false}) async {
    final data = await _addressService.getProvinces(regionCode);
    if (!mounted) return;
    setState(() {
      _provinces = data;
      if (!preselectExisting) {
        _selectedProvinceCode = null;
        _selectedCityCode = null;
        _selectedBarangayCode = null;
        _cities = [];
        _barangays = [];
      }
    });

    if (preselectExisting && widget.existing?.province != null) {
      final match = _provinces.cast<Province?>().firstWhere(
        (p) => p?.name == widget.existing!.province,
        orElse: () => null,
      );
      if (match != null) {
        setState(() => _selectedProvinceCode = match.code);
        await _loadCities(match.code, preselectExisting: true);
      }
    }
  }

  Future<void> _loadCities(String provinceCode,
      {bool preselectExisting = false}) async {
    final data = await _addressService.getCities(provinceCode);
    if (!mounted) return;
    setState(() {
      _cities = data;
      if (!preselectExisting) {
        _selectedCityCode = null;
        _selectedBarangayCode = null;
        _barangays = [];
      }
    });

    if (preselectExisting && widget.existing?.cityOrMunicipality != null) {
      final match = _cities.cast<CityMunicipality?>().firstWhere(
        (c) => c?.name == widget.existing!.cityOrMunicipality,
        orElse: () => null,
      );
      if (match != null) {
        setState(() => _selectedCityCode = match.code);
        await _loadBarangays(match.code, preselectExisting: true);
      }
    }
  }

  Future<void> _loadBarangays(String cityCode,
      {bool preselectExisting = false}) async {
    final data = await _addressService.getBarangays(cityCode);
    if (!mounted) return;
    setState(() {
      _barangays = data;
      if (!preselectExisting) _selectedBarangayCode = null;
    });

    if (preselectExisting && widget.existing?.barangay != null) {
      final match = _barangays.cast<Barangay?>().firstWhere(
        (b) => b?.name == widget.existing!.barangay,
        orElse: () => null,
      );
      if (match != null) {
        setState(() => _selectedBarangayCode = match.code);
      }
    }
  }

  // ── Save ──────────────────────────────────────────────────────────

  Future<void> _save() async {
    final label  = _labelController.text.trim();
    final street = _streetController.text.trim();
    final postal = _postalController.text.trim();

    if (label.isEmpty ||
        street.isEmpty ||
        _selectedRegionCode == null ||
        _selectedProvinceCode == null ||
        _selectedCityCode == null ||
        _selectedBarangayCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill label, street, region, province, city, and barangay.',
          ),
        ),
      );
      return;
    }

    final id = widget.existing?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final regionName = _regions
        .firstWhere((r) => r.code == _selectedRegionCode,
            orElse: () => const Region(code: '', name: ''))
        .name;
    final provinceName = _provinces
        .firstWhere((p) => p.code == _selectedProvinceCode,
            orElse: () => const Province(code: '', name: '', regionCode: ''))
        .name;
    final cityName = _cities
        .firstWhere((c) => c.code == _selectedCityCode,
            orElse: () =>
                const CityMunicipality(code: '', name: '', provinceCode: ''))
        .name;
    final barangayName = _barangays
        .firstWhere((b) => b.code == _selectedBarangayCode,
            orElse: () => const Barangay(code: '', name: '', cityCode: ''))
        .name;

    final displayFull = '$street, $barangayName, $cityName, $provinceName';

    final addr = Address(
      id: id,
      label: label,
      fullAddress: displayFull,
      city: cityName,
      postalCode: postal.isEmpty ? null : postal,
      isDefault: _isDefault || widget.profile.addresses.isEmpty,
      region: regionName,
      province: provinceName,
      cityOrMunicipality: cityName,
      barangay: barangayName,
      street: street,
    );

    if (widget.index != null) {
      await widget.profile.updateAddress(widget.index!, addr);
    } else {
      await widget.profile.addAddress(addr);
    }

    if (_isDefault || widget.profile.addresses.length == 1) {
      await widget.profile.setDefaultAddress(id);
    }

    if (mounted) Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Sheet handle ────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                widget.existing == null ? 'Add address' : 'Edit address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // ── Label ───────────────────────────────────────────
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office)',
                ),
              ),
              const SizedBox(height: 12),

              // ── Region ──────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _selectedRegionCode,
                decoration: const InputDecoration(labelText: 'Region'),
                items: _regions
                    .map((r) => DropdownMenuItem(
                          value: r.code,
                          child: Text(r.name),
                        ))
                    .toList(),
                onChanged: (code) {
                  setState(() => _selectedRegionCode = code);
                  if (code != null) _loadProvinces(code);
                },
              ),
              const SizedBox(height: 12),

              // ── Province ─────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _selectedProvinceCode,
                decoration: const InputDecoration(labelText: 'Province'),
                items: _provinces
                    .map((p) => DropdownMenuItem(
                          value: p.code,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (code) {
                  setState(() => _selectedProvinceCode = code);
                  if (code != null) _loadCities(code);
                },
              ),
              const SizedBox(height: 12),

              // ── City / Municipality ───────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _selectedCityCode,
                decoration:
                    const InputDecoration(labelText: 'City / Municipality'),
                items: _cities
                    .map((c) => DropdownMenuItem(
                          value: c.code,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (code) {
                  setState(() => _selectedCityCode = code);
                  if (code != null) _loadBarangays(code);
                },
              ),
              const SizedBox(height: 12),

              // ── Barangay ─────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _selectedBarangayCode,
                decoration: const InputDecoration(labelText: 'Barangay'),
                items: _barangays
                    .map((b) => DropdownMenuItem(
                          value: b.code,
                          child: Text(b.name),
                        ))
                    .toList(),
                onChanged: (code) => setState(() => _selectedBarangayCode = code),
              ),
              const SizedBox(height: 12),

              // ── Street ───────────────────────────────────────────
              TextField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street / House / Building',
                ),
              ),
              const SizedBox(height: 12),

              // ── Postal code ──────────────────────────────────────
              TextField(
                controller: _postalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Postal code'),
              ),
              const SizedBox(height: 12),

              // ── Default toggle ───────────────────────────────────
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: const Text('Set as default address'),
              ),
              const SizedBox(height: 24),

              // ── Save button ──────────────────────────────────────
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}