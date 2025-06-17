import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer/thai_address.dart';
import '../global.dart' as global;

class ThaiAddressService {
  // Get provinces from API
  static Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('${global.apiBaseUrl()}/get/provinces'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['data'] != null) {
          List<Province> provinces = [];
          for (var item in data['data']) {
            provinces.add(Province.fromApiJson(item));
          }
          return provinces;
        }
      }
      throw Exception('Failed to load provinces');
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  // Get districts by province ID from API
  static Future<List<District>> getDistrictsByProvinceId(int provinceId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${global.apiBaseUrl()}/get/amphures?province_id=$provinceId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['data'] != null) {
          List<District> districts = [];
          for (var item in data['data']) {
            districts.add(District.fromApiJson(item));
          }
          return districts;
        }
      }
      throw Exception('Failed to load districts');
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  // Get subdistricts by district ID from API
  static Future<List<Subdistrict>> getSubdistrictsByDistrictId(
    int districtId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${global.apiBaseUrl()}/get/tambons?amphure_id=$districtId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['data'] != null) {
          List<Subdistrict> subdistricts = [];
          for (var item in data['data']) {
            subdistricts.add(Subdistrict.fromApiJson(item));
          }
          return subdistricts;
        }
      }
      throw Exception('Failed to load subdistricts');
    } catch (e) {
      throw Exception('Error fetching subdistricts: $e');
    }
  }

  // Search address by zipcode from API
  static Future<List<Map<String, dynamic>>> searchByZipcode(
    String zipcode,
  ) async {
    try {
      // Convert zipcode string to integer
      final zipcodeInt = int.tryParse(zipcode);
      if (zipcodeInt == null) {
        throw Exception('Invalid zipcode format');
      }

      final response = await http.post(
        Uri.parse('${global.apiBaseUrl()}/get/findbyzipcode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'zip_code': zipcodeInt}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        if (data['success'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(
            data['data'],
          ); // Return empty list
        }
      }
      throw Exception('Failed to search by zipcode');
    } catch (e) {
      throw Exception('Error searching by zipcode: $e');
    }
  }

  // Get province by ID from API
  static Future<Province?> getProvinceById(int id) async {
    try {
      final provinces = await getProvinces();
      return provinces.firstWhere(
        (province) => province.id == id,
        orElse: () => throw Exception('Province not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Get district by ID from API
  static Future<District?> getDistrictById(int id) async {
    try {
      // Get all provinces to find the correct province for this district
      final provinces = await getProvinces();

      for (Province province in provinces) {
        try {
          final districts = await getDistrictsByProvinceId(province.id);
          final district = districts.firstWhere(
            (d) => d.id == id,
            orElse: () =>
                throw Exception('District not found in this province'),
          );
          return district;
        } catch (e) {
          // Continue to next province
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get subdistrict by ID from API
  static Future<Subdistrict?> getSubdistrictById(int id) async {
    try {
      // Get all provinces to find the correct subdistrict
      final provinces = await getProvinces();

      for (Province province in provinces) {
        try {
          final districts = await getDistrictsByProvinceId(province.id);

          for (District district in districts) {
            try {
              final subdistricts = await getSubdistrictsByDistrictId(
                district.id,
              );
              final subdistrict = subdistricts.firstWhere(
                (s) => s.id == id,
                orElse: () =>
                    throw Exception('Subdistrict not found in this district'),
              );
              return subdistrict;
            } catch (e) {
              // Continue to next district
              continue;
            }
          }
        } catch (e) {
          // Continue to next province
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get districts by province name (for backward compatibility)
  static Future<List<District>> getDistrictsByProvince(
    String provinceName,
  ) async {
    try {
      final provinces = await getProvinces();
      final province = provinces.firstWhere(
        (p) => p.name == provinceName,
        orElse: () => throw Exception('Province not found'),
      );
      return await getDistrictsByProvinceId(province.id);
    } catch (e) {
      throw Exception('Error fetching districts by province name: $e');
    }
  }

  // Get subdistricts by district and province names (for backward compatibility)
  static Future<List<Subdistrict>> getSubdistrictsByDistrict(
    String districtName,
    String provinceName,
  ) async {
    try {
      final districts = await getDistrictsByProvince(provinceName);
      final district = districts.firstWhere(
        (d) => d.name == districtName,
        orElse: () => throw Exception('District not found'),
      );
      return await getSubdistrictsByDistrictId(district.id);
    } catch (e) {
      throw Exception('Error fetching subdistricts by district name: $e');
    }
  }
}
