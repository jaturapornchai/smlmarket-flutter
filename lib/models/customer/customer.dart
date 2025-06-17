import 'package:equatable/equatable.dart';

enum CustomerType {
  individual, // บุคคลธรรมดา
  company, // นิติบุคคล
}

class Customer extends Equatable {
  final int? customerId;
  final CustomerType customerType;
  final String taxId; // เลขประจำตัวผู้เสียภาษี 13 หลัก (ไม่บังคับ)
  final String? title; // คำนำหน้าชื่อ
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String addressLine1;
  final String? addressLine2;
  final String? subdistrict; // ตำบล/แขวง
  final String district; // อำเภอ/เขต
  final String province; // จังหวัด
  final String postalCode; // รหัสไปรษณีย์ 5 หลัก
  final String? phone;
  final String? email; // Optional
  final CustomerStatus status;
  // LINE OA Integration fields
  final String? lineUserId; // LINE User ID for OA integration
  final String? lineDisplayName; // LINE Display Name
  final bool isLineConnected; // Whether LINE OA is connected
  final DateTime?
  lineConnectedAt; // When LINE was connected  // Additional status fields
  final bool isVerified; // Whether customer is verified
  final DateTime? verifiedAt; // When customer was verified
  final String? notes; // Additional notes about customer

  const Customer({
    this.customerId,
    required this.customerType,
    this.taxId = '', // Default to empty string (optional)
    this.title,
    this.firstName,
    this.lastName,
    this.companyName,
    required this.addressLine1,
    this.addressLine2,
    this.subdistrict,
    required this.district,
    required this.province,
    required this.postalCode,
    this.phone,
    this.email, // Optional
    this.status = CustomerStatus.active,
    // LINE OA Integration
    this.lineUserId,
    this.lineDisplayName,
    this.isLineConnected = false,
    this.lineConnectedAt,
    // Additional status fields
    this.isVerified = false,
    this.verifiedAt,
    this.notes,
  });
  Customer copyWith({
    int? customerId,
    CustomerType? customerType,
    String? taxId,
    String? title,
    String? firstName,
    String? lastName,
    String? companyName,
    String? addressLine1,
    String? addressLine2,
    String? subdistrict,
    String? district,
    String? province,
    String? postalCode,
    String? phone,
    String? email,
    CustomerStatus? status,
    String? lineUserId,
    String? lineDisplayName,
    bool? isLineConnected,
    DateTime? lineConnectedAt,
    bool? isVerified,
    DateTime? verifiedAt,
    String? notes,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      customerType: customerType ?? this.customerType,
      taxId: taxId ?? this.taxId,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      subdistrict: subdistrict ?? this.subdistrict,
      district: district ?? this.district,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      lineUserId: lineUserId ?? this.lineUserId,
      lineDisplayName: lineDisplayName ?? this.lineDisplayName,
      isLineConnected: isLineConnected ?? this.isLineConnected,
      lineConnectedAt: lineConnectedAt ?? this.lineConnectedAt,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    customerId,
    customerType,
    taxId,
    title,
    firstName,
    lastName,
    companyName,
    addressLine1,
    addressLine2,
    subdistrict,
    district,
    province,
    postalCode,
    phone,
    email,
    status,
    lineUserId,
    lineDisplayName,
    isLineConnected,
    lineConnectedAt,
    isVerified,
    verifiedAt,
    notes,
  ];
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_type': customerType == CustomerType.individual
          ? 'individual'
          : 'company',
      'tax_id': taxId,
      'title': title,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'status': status == CustomerStatus.active ? 'active' : 'inactive',
      'line_user_id': lineUserId,
      'line_display_name': lineDisplayName,
      'is_line_connected': isLineConnected,
      'line_connected_at': lineConnectedAt?.toIso8601String(),
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      customerType: json['customer_type'] == 'company'
          ? CustomerType.company
          : CustomerType.individual,
      taxId: json['tax_id'] ?? '',
      title: json['title'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      companyName: json['company_name'],
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      subdistrict: json['subdistrict'],
      district: json['district'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phone: json['phone'],
      email: json['email'],
      status: json['status'] == 'inactive'
          ? CustomerStatus.inactive
          : CustomerStatus.active,
      lineUserId: json['line_user_id'],
      lineDisplayName: json['line_display_name'],
      isLineConnected: json['is_line_connected'] ?? false,
      lineConnectedAt: json['line_connected_at'] != null
          ? DateTime.parse(json['line_connected_at'])
          : null,
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      notes: json['notes'],
    );
  }

  // Helper methods
  bool get isIndividual => customerType == CustomerType.individual;
  bool get isCompany => customerType == CustomerType.company;
  bool get isActive => status == CustomerStatus.active;

  String get displayName {
    if (isCompany) {
      return companyName ?? 'ไม่ระบุชื่อบริษัท';
    } else {
      final name = [
        title,
        firstName,
        lastName,
      ].where((s) => s?.isNotEmpty == true).join(' ');
      return name.isNotEmpty ? name : 'ไม่ระบุชื่อ';
    }
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      subdistrict,
      district,
      province,
      postalCode,
    ].where((s) => s?.isNotEmpty == true);
    return parts.join(' ');
  }

  // Validation methods
  bool get isValidTaxId =>
      taxId.isEmpty ||
      (taxId.length == 13 && RegExp(r'^\d{13}$').hasMatch(taxId));
  bool get isValidPostalCode =>
      postalCode.length == 5 && RegExp(r'^\d{5}$').hasMatch(postalCode);
  bool get isValid {
    // Basic address validation (required for both types)
    if (!isValidPostalCode) return false;
    if (addressLine1.isEmpty) return false;
    if (district.isEmpty) return false;
    if (province.isEmpty) return false;

    // Type-specific validation
    if (isIndividual) {
      // Individual person validation
      // - Must have first name and last name
      if (firstName?.isEmpty != false || lastName?.isEmpty != false) {
        return false;
      }
      // - Tax ID is optional, but if provided must be valid (13 digits)
      if (taxId.isNotEmpty && !RegExp(r'^\d{13}$').hasMatch(taxId)) {
        return false;
      }
      // - Phone is optional
      // - Email is optional
    } else {
      // Company validation
      // - Must have company name
      if (companyName?.isEmpty != false) return false;
      // - Must have tax ID (13 digits)
      if (taxId.isEmpty || !RegExp(r'^\d{13}$').hasMatch(taxId)) return false;
      // - Phone is optional
      // - Email is optional
    }

    return true;
  }
}

enum CustomerStatus { active, inactive }

extension CustomerTypeExtension on CustomerType {
  String get displayName {
    switch (this) {
      case CustomerType.individual:
        return 'บุคคลธรรมดา';
      case CustomerType.company:
        return 'นิติบุคคล';
    }
  }
}
