class Address {
  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    this.postalCode,
    this.isDefault = false,
    this.region,
    this.province,
    this.cityOrMunicipality,
    this.barangay,
    this.street,
  });

  final String id;
  final String label;

  // Backward-compatible display fields used across the UI.
  final String fullAddress;
  final String city;
  final String? postalCode;
  final bool isDefault;

  // Structured address fields for cascading selection.
  final String? region;
  final String? province;
  final String? cityOrMunicipality;
  final String? barangay;
  final String? street;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fullAddress': fullAddress,
    'city': city,
    'postalCode': postalCode,
    'isDefault': isDefault,
    'region': region,
    'province': province,
    'cityOrMunicipality': cityOrMunicipality,
    'barangay': barangay,
    'street': street,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    label: json['label'] as String,
    fullAddress: json['fullAddress'] as String? ?? '',
    city: json['city'] as String? ?? '',
    postalCode: json['postalCode'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
    region: json['region'] as String?,
    province: json['province'] as String?,
    cityOrMunicipality: json['cityOrMunicipality'] as String?,
    barangay: json['barangay'] as String?,
    street: json['street'] as String?,
  );

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? postalCode,
    bool? isDefault,
    String? region,
    String? province,
    String? cityOrMunicipality,
    String? barangay,
    String? street,
  }) => Address(
    id: id ?? this.id,
    label: label ?? this.label,
    fullAddress: fullAddress ?? this.fullAddress,
    city: city ?? this.city,
    postalCode: postalCode ?? this.postalCode,
    isDefault: isDefault ?? this.isDefault,
    region: region ?? this.region,
    province: province ?? this.province,
    cityOrMunicipality: cityOrMunicipality ?? this.cityOrMunicipality,
    barangay: barangay ?? this.barangay,
    street: street ?? this.street,
  );
}
