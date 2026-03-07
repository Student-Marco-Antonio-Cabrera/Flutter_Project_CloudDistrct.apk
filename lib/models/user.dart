import 'address.dart';

class User {
  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone,
    this.profileImagePath,
    this.addresses = const [],
  });
  final String id;
  final String email;
  final String displayName;
  final String? phone;
  final String? profileImagePath;
  final List<Address> addresses;
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'phone': phone,
    'profileImagePath': profileImagePath,
    'addresses': addresses.map((a) => a.toJson()).toList(),
  };
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    phone: json['phone'] as String?,
    profileImagePath: json['profileImagePath'] as String?,
    addresses:
        (json['addresses'] as List<dynamic>?)
            ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    String? profileImagePath,
    List<Address>? addresses,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    profileImagePath: profileImagePath ?? this.profileImagePath,
    addresses: addresses ?? this.addresses,
  );
}
