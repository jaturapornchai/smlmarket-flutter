import 'package:equatable/equatable.dart';

class ThaiAddress extends Equatable {
  final String? subdistrict; // ตำบล/แขวง
  final String district; // อำเภอ/เขต
  final String province; // จังหวัด
  final String postalCode; // รหัสไปรษณีย์

  const ThaiAddress({
    this.subdistrict,
    required this.district,
    required this.province,
    required this.postalCode,
  });

  @override
  List<Object?> get props => [subdistrict, district, province, postalCode];

  Map<String, dynamic> toJson() {
    return {
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'postal_code': postalCode,
    };
  }

  factory ThaiAddress.fromJson(Map<String, dynamic> json) {
    return ThaiAddress(
      subdistrict: json['subdistrict'],
      district: json['district'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'] ?? '',
    );
  }

  // สำหรับ API ใหม่ /get/findbyzipcode
  factory ThaiAddress.fromLocationData(Map<String, dynamic> json) {
    return ThaiAddress(
      subdistrict: json['tambon']?['name_th'],
      district: json['amphure']?['name_th'] ?? '',
      province: json['province']?['name_th'] ?? '',
      postalCode: json['tambon']?['zip_code']?.toString() ?? '',
    );
  }
}

class Province extends Equatable {
  final int id;
  final String name;
  final String nameEn;

  const Province({required this.id, required this.name, required this.nameEn});

  @override
  List<Object?> get props => [id, name, nameEn];

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'name_en': nameEn};
  }

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }

  // สำหรับ API ใหม่ /get/provinces
  factory Province.fromApiJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] ?? 0,
      name: json['name_th'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }
}

class District extends Equatable {
  final int id;
  final String name;
  final String nameEn;
  final String provinceName;

  const District({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.provinceName,
  });

  @override
  List<Object?> get props => [id, name, nameEn, provinceName];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'province_name': provinceName,
    };
  }

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      provinceName: json['province_name'] ?? '',
    );
  }

  // สำหรับ API ใหม่ /get/amphures
  factory District.fromApiJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? 0,
      name: json['name_th'] ?? '',
      nameEn: json['name_en'] ?? '',
      provinceName: json['province_name'] ?? '',
    );
  }
}

class Subdistrict extends Equatable {
  final int id;
  final String name;
  final String nameEn;
  final String districtName;
  final String provinceName;
  final String postalCode;

  const Subdistrict({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.districtName,
    required this.provinceName,
    required this.postalCode,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    districtName,
    provinceName,
    postalCode,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'district_name': districtName,
      'province_name': provinceName,
      'postal_code': postalCode,
    };
  }

  factory Subdistrict.fromJson(Map<String, dynamic> json) {
    return Subdistrict(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      districtName: json['district_name'] ?? '',
      provinceName: json['province_name'] ?? '',
      postalCode: json['postal_code'] ?? '',
    );
  }

  // สำหรับ API ใหม่ /get/tambons
  factory Subdistrict.fromApiJson(Map<String, dynamic> json) {
    return Subdistrict(
      id: json['id'] ?? 0,
      name: json['name_th'] ?? '',
      nameEn: json['name_en'] ?? '',
      districtName: json['district_name'] ?? '',
      provinceName: json['province_name'] ?? '',
      postalCode: json['zip_code']?.toString() ?? '',
    );
  }
}

class CompanyInfo extends Equatable {
  final String taxId;
  final String companyName;
  final String address;
  final String status;

  const CompanyInfo({
    required this.taxId,
    required this.companyName,
    required this.address,
    required this.status,
  });

  @override
  List<Object?> get props => [taxId, companyName, address, status];

  Map<String, dynamic> toJson() {
    return {
      'tax_id': taxId,
      'company_name': companyName,
      'address': address,
      'status': status,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      taxId: json['tax_id'] ?? '',
      companyName: json['company_name'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
