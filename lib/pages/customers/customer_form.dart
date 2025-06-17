import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/customer/customer.dart';
import '../../models/customer/thai_address.dart';
import '../../services/customer/customer_service.dart';
import '../../services/auth_service.dart';
import '../../services/thai_address_service.dart' as thai_service;
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer; // null for new customer
  final bool isReadOnly;

  const CustomerForm({super.key, this.customer, this.isReadOnly = false});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();
  final _authService = AuthService();

  // Controllers
  final _taxIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _subdistrictController = TextEditingController();
  final _lineUserIdController = TextEditingController();
  final _lineDisplayNameController = TextEditingController();
  final _notesController = TextEditingController();
  CustomerType _customerType = CustomerType.individual;
  CustomerStatus _status = CustomerStatus.active;
  bool _isLoading = false;
  bool _isLookingUpTaxId = false;
  bool _isSearchingPostalCode = false;
  bool _isLineConnected = false;
  bool _isVerified = false;
  List<Map<String, dynamic>> _postalCodeSuggestions = [];
  bool _showPostalCodeDropdown = false;
  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  @override
  void dispose() {
    _taxIdController.dispose();
    _titleController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _postalCodeController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _subdistrictController.dispose();
    _lineUserIdController.dispose();
    _lineDisplayNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadCustomerData() {
    if (widget.customer != null) {
      final customer = widget.customer!;
      _taxIdController.text = customer.taxId;
      _titleController.text = customer.title ?? '';
      _firstNameController.text = customer.firstName ?? '';
      _lastNameController.text = customer.lastName ?? '';
      _companyNameController.text = customer.companyName ?? '';
      _addressLine1Controller.text = customer.addressLine1;
      _addressLine2Controller.text = customer.addressLine2 ?? '';
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _postalCodeController.text = customer.postalCode;
      _provinceController.text = customer.province;
      _districtController.text = customer.district;
      _subdistrictController.text = customer.subdistrict ?? '';
      _lineUserIdController.text = customer.lineUserId ?? '';
      _lineDisplayNameController.text = customer.lineDisplayName ?? '';
      _notesController.text = customer.notes ?? '';
      _customerType = customer.customerType;
      _status = customer.status;
      _isLineConnected = customer.isLineConnected;
      _isVerified = customer.isVerified;
    } else {
      // New customer - set email from current user if customer
      final currentUser = _authService.currentUser;
      if (currentUser?.isCustomer == true) {
        _emailController.text = currentUser!.email;
      }
    }
  }

  // Search provinces
  Future<void> _searchProvinces() async {
    try {
      final provinces = await thai_service.ThaiAddressService.getProvinces();
      if (provinces.isNotEmpty) {
        _showProvinceSelectionDialog(provinces);
      } else {
        _showMessage('ไม่พบข้อมูลจังหวัด');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาดในการค้นหาจังหวัด: $e');
    }
  }

  // Search districts by province
  Future<void> _searchDistricts() async {
    if (_provinceController.text.isEmpty) {
      _showMessage('กรุณาเลือกจังหวัดก่อน');
      return;
    }

    try {
      final districts = await thai_service
          .ThaiAddressService.getDistrictsByProvince(_provinceController.text);
      if (districts.isNotEmpty) {
        _showDistrictSelectionDialog(districts);
      } else {
        _showMessage('ไม่พบข้อมูลอำเภอ');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาดในการค้นหาอำเภอ: $e');
    }
  }

  // Search subdistricts by district and province
  Future<void> _searchSubdistricts() async {
    if (_provinceController.text.isEmpty) {
      _showMessage('กรุณาเลือกจังหวัดก่อน');
      return;
    }
    if (_districtController.text.isEmpty) {
      _showMessage('กรุณาเลือกอำเภอก่อน');
      return;
    }

    try {
      final subdistricts =
          await thai_service.ThaiAddressService.getSubdistrictsByDistrict(
            _districtController.text,
            _provinceController.text,
          );
      if (subdistricts.isNotEmpty) {
        _showSubdistrictSelectionDialog(subdistricts);
      } else {
        _showMessage('ไม่พบข้อมูลตำบล');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาดในการค้นหาตำบล: $e');
    }
  }

  Future<void> _lookupTaxId() async {
    final taxId = _taxIdController.text.trim();
    if (taxId.isEmpty) {
      // Just show feature info without error message
      _showMessage('ฟีเจอร์ค้นหาข้อมูลบริษัทจะพัฒนาใน API รุ่นต่อไป');
      return;
    }
    // TODO: Implement company lookup via SMLGOAPI if needed
    _showMessage('ฟีเจอร์ค้นหาข้อมูลบริษัทจะพัฒนาใน API รุ่นต่อไป');
  }

  Future<void> _searchPostalCodeSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _postalCodeSuggestions = [];
        _showPostalCodeDropdown = false;
      });
      return;
    }

    setState(() {
      _isSearchingPostalCode = true;
    });

    try {
      if (query.length >= 3) {
        // Search when user types at least 3 digits
        final addressData = await thai_service
            .ThaiAddressService.searchByZipcode(query.padRight(5, '0'));
        setState(() {
          _postalCodeSuggestions = addressData;
          _showPostalCodeDropdown = addressData.isNotEmpty;
          _isSearchingPostalCode = false;
        });
      }
    } catch (e) {
      // If exact search fails, try without padding for partial matches
      try {
        if (query.length == 5) {
          final addressData =
              await thai_service.ThaiAddressService.searchByZipcode(query);
          setState(() {
            _postalCodeSuggestions = addressData;
            _showPostalCodeDropdown = addressData.isNotEmpty;
            _isSearchingPostalCode = false;
          });
        } else {
          setState(() {
            _postalCodeSuggestions = [];
            _showPostalCodeDropdown = false;
            _isSearchingPostalCode = false;
          });
        }
      } catch (e2) {
        setState(() {
          _postalCodeSuggestions = [];
          _showPostalCodeDropdown = false;
          _isSearchingPostalCode = false;
        });
      }
    }
  }

  void _onPostalCodeSuggestionSelected(Map<String, dynamic> suggestion) {
    setState(() {
      _showPostalCodeDropdown = false;
    });

    // Extract data from the new API response format
    final province = suggestion['province'];
    final amphure = suggestion['amphure'];
    final tambon = suggestion['tambon'];

    _applySelectedAddress(
      province?['name_th'] ?? '',
      amphure?['name_th'] ?? '',
      tambon?['name_th'] ?? '',
    );

    _showMessage('เติมข้อมูลที่อยู่จากรหัสไปรษณีย์แล้ว');
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check user permissions
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showMessage('กรุณาเข้าสู่ระบบก่อน');
      return;
    }

    // Customers can only edit their own data
    if (currentUser.isCustomer &&
        widget.customer != null &&
        widget.customer!.email != currentUser.email) {
      _showMessage('คุณสามารถแก้ไขข้อมูลของตัวเองเท่านั้น');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customer = Customer(
        customerId: widget.customer?.customerId,
        customerType: _customerType,
        taxId: _taxIdController.text,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        firstName: _firstNameController.text.isEmpty
            ? null
            : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty
            ? null
            : _lastNameController.text,
        companyName: _companyNameController.text.isEmpty
            ? null
            : _companyNameController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty
            ? null
            : _addressLine2Controller.text,
        subdistrict: _subdistrictController.text.isEmpty
            ? null
            : _subdistrictController.text,
        district: _districtController.text,
        province: _provinceController.text,
        postalCode: _postalCodeController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        status: _status,
        isLineConnected: _isLineConnected,
        lineUserId: _lineUserIdController.text.isEmpty
            ? null
            : _lineUserIdController.text,
        lineDisplayName: _lineDisplayNameController.text.isEmpty
            ? null
            : _lineDisplayNameController.text,
        lineConnectedAt: _isLineConnected
            ? (widget.customer?.lineConnectedAt ?? DateTime.now())
            : null,
        isVerified: _isVerified,
        verifiedAt: _isVerified
            ? (widget.customer?.verifiedAt ?? DateTime.now())
            : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (!customer.isValid) {
        _showMessage('กรุณาตรวจสอบข้อมูลให้ครบถ้วนและถูกต้อง');
        return;
      }

      final savedCustomer = await _customerService.saveCustomer(customer);
      if (savedCustomer != null) {
        _showMessage(
          widget.customer == null
              ? 'บันทึกข้อมูลลูกค้าใหม่แล้ว'
              : 'อัปเดตข้อมูลลูกค้าแล้ว',
        );
        if (mounted) {
          Navigator.of(context).pop(savedCustomer);
        }
      } else {
        _showMessage('เกิดข้อผิดพลาดในการบันทึกข้อมูล');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool get _canEdit {
    if (widget.isReadOnly) return false;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    // Admin and staff can edit all customers
    if (currentUser.isAdmin || currentUser.isEmployee) return true;

    // Customers can only edit their own data
    if (currentUser.isCustomer) {
      if (widget.customer == null) return true; // New customer
      return widget.customer!.email == currentUser.email;
    }
    return false;
  }

  void _applySelectedAddress(
    String province,
    String district,
    String subdistrict,
  ) {
    setState(() {
      _provinceController.text = province;
      _districtController.text = district;
      _subdistrictController.text = subdistrict;
    });

    _showMessage('เติมข้อมูลที่อยู่จากรหัสไปรษณีย์แล้ว');
  }

  void _hidePostalCodeDropdown() {
    setState(() {
      _showPostalCodeDropdown = false;
    });
  }

  // Show province selection dialog
  void _showProvinceSelectionDialog(List<Province> provinces) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกจังหวัด'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              final province = provinces[index];
              return ListTile(
                title: Text(province.name),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _provinceController.text = province.name;
                    _districtController.clear();
                    _subdistrictController.clear();
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  // Show district selection dialog
  void _showDistrictSelectionDialog(List<District> districts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกอำเภอ'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: districts.length,
            itemBuilder: (context, index) {
              final district = districts[index];
              return ListTile(
                title: Text(district.name),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _districtController.text = district.name;
                    _subdistrictController.clear();
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  // Show subdistrict selection dialog
  void _showSubdistrictSelectionDialog(List<Subdistrict> subdistricts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกตำบล'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: subdistricts.length,
            itemBuilder: (context, index) {
              final subdistrict = subdistricts[index];
              return ListTile(
                title: Text(subdistrict.name),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _subdistrictController.text = subdistrict.name;
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.customer == null ? 'เพิ่มข้อมูลลูกค้า' : 'แก้ไขข้อมูลลูกค้า',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_canEdit)
            TextButton(
              onPressed: _isLoading ? null : _saveCustomer,
              child: Text(
                _isLoading ? 'กำลังบันทึก...' : 'บันทึก',
                style: TextStyle(
                  color: _isLoading
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: _hidePostalCodeDropdown,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerTypeSection(),
                  const SizedBox(height: 24),
                  _buildTaxIdSection(),
                  const SizedBox(height: 24),
                  _buildNameSection(),
                  const SizedBox(height: 24),
                  _buildAddressSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  if (_authService.currentUser?.isAdmin == true) ...[
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildLineOASection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTypeSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ประเภทลูกค้า',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<CustomerType>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('บุคคลธรรมดา'),
                  value: CustomerType.individual,
                  groupValue: _customerType,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _customerType = value!;
                          });
                        }
                      : null,
                ),
              ),
              Expanded(
                child: RadioListTile<CustomerType>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('นิติบุคคล'),
                  value: CustomerType.company,
                  groupValue: _customerType,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _customerType = value!;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxIdSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลขประจำตัวผู้เสียภาษี',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _taxIdController,
                  enabled: _canEdit,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  decoration: InputDecoration(
                    labelText: _customerType == CustomerType.company
                        ? 'เลขประจำตัวผู้เสียภาษี 13 หลัก *'
                        : 'เลขประจำตัวผู้เสียภาษี 13 หลัก (ไม่บังคับ)',
                    hintText: _customerType == CustomerType.company
                        ? 'เลขประจำตัวผู้เสียภาษี 13 หลัก *'
                        : 'เลขประจำตัวผู้เสียภาษี 13 หลัก (ไม่บังคับ)',
                    border: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (_customerType == CustomerType.company) {
                      // Company must have tax ID
                      if (value?.isEmpty == true) {
                        return 'นิติบุคคลต้องมีเลขประจำตัวผู้เสียภาษี';
                      }
                      if (value?.length != 13) {
                        return 'เลขประจำตัวผู้เสียภาษีต้องเป็น 13 หลัก';
                      }
                    } else {
                      // Individual: optional but if provided must be valid
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length != 13) {
                        return 'เลขประจำตัวผู้เสียภาษีต้องเป็น 13 หลัก';
                      }
                    }
                    return null;
                  },
                ),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isLookingUpTaxId ? null : _lookupTaxId,
                  icon: _isLookingUpTaxId
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('ค้นหา'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _customerType == CustomerType.individual
                ? 'ข้อมูลบุคคล'
                : 'ข้อมูลบริษัท',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_customerType == CustomerType.individual) ...[
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _titleController,
                    enabled: _canEdit,
                    decoration: const InputDecoration(
                      labelText: 'คำนำหน้า',
                      hintText: 'คำนำหน้า',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    enabled: _canEdit,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ *',
                      hintText: 'ชื่อ *',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    validator: (value) {
                      if (_customerType == CustomerType.individual &&
                          (value?.isEmpty == true)) {
                        return 'กรุณาใส่ชื่อ';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    enabled: _canEdit,
                    decoration: const InputDecoration(
                      labelText: 'นามสกุล *',
                      hintText: 'นามสกุล *',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    validator: (value) {
                      if (_customerType == CustomerType.individual &&
                          (value?.isEmpty == true)) {
                        return 'กรุณาใส่นามสกุล';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            TextFormField(
              controller: _companyNameController,
              enabled: _canEdit,
              decoration: const InputDecoration(
                labelText: 'ชื่อบริษัท/ห้างร้าน *',
                hintText: 'ชื่อบริษัท/ห้างร้าน *',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              validator: (value) {
                if (_customerType == CustomerType.company &&
                    (value?.isEmpty == true)) {
                  return 'กรุณาใส่ชื่อบริษัท';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ที่อยู่',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12), // Address lines
          TextFormField(
            controller: _addressLine1Controller,
            enabled: _canEdit,
            decoration: const InputDecoration(
              labelText: 'ที่อยู่หลัก (บ้านเลขที่ ซอย ถนน) *',
              hintText: 'ที่อยู่หลัก (บ้านเลขที่ ซอย ถนน) *',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'กรุณาใส่ที่อยู่หลัก';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _addressLine2Controller,
            enabled: _canEdit,
            decoration: const InputDecoration(
              labelText: 'ที่อยู่เพิ่มเติม (ไม่บังคับ)',
              hintText: 'ที่อยู่เพิ่มเติม (ไม่บังคับ)',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
          const SizedBox(height: 12), // Postal code with auto-complete dropdown
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _postalCodeController,
                      enabled: _canEdit,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: InputDecoration(
                        labelText: 'รหัสไปรษณีย์ *',
                        hintText: 'รหัสไปรษณีย์ *',
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        suffixIcon: _isSearchingPostalCode
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                      ),
                      onChanged: _canEdit ? _searchPostalCodeSuggestions : null,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'กรุณาใส่รหัสไปรษณีย์';
                        }
                        if (value?.length != 5) {
                          return 'รหัสไปรษณีย์ต้องเป็น 5 หลัก';
                        }
                        return null;
                      },
                    ),
                    // Dropdown suggestions
                    if (_showPostalCodeDropdown &&
                        _postalCodeSuggestions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _postalCodeSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _postalCodeSuggestions[index];
                            final province = suggestion['province'];
                            final amphure = suggestion['amphure'];
                            final tambon = suggestion['tambon'];
                            return ListTile(
                              dense: true,
                              title: Text(
                                '${tambon?['name_th'] ?? ''}, ${amphure?['name_th'] ?? ''}, ${province?['name_th'] ?? ''}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                'รหัสไปรษณีย์: ${tambon?['zip_code']?.toString() ?? _postalCodeController.text}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              onTap: () =>
                                  _onPostalCodeSuggestionSelected(suggestion),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Province field with search button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _provinceController,
                  enabled: _canEdit,
                  decoration: const InputDecoration(
                    labelText: 'จังหวัด *',
                    hintText: 'จังหวัด *',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'กรุณาใส่จังหวัด';
                    }
                    return null;
                  },
                ),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchProvinces,
                  child: const Text('ค้นหา'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // District field with search button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _districtController,
                  enabled: _canEdit,
                  decoration: const InputDecoration(
                    labelText: 'อำเภอ/เขต *',
                    hintText: 'อำเภอ/เขต *',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'กรุณาใส่อำเภอ/เขต';
                    }
                    return null;
                  },
                ),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchDistricts,
                  child: const Text('ค้นหา'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Subdistrict field with search button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _subdistrictController,
                  enabled: _canEdit,
                  decoration: const InputDecoration(
                    labelText: 'ตำบล/แขวง',
                    hintText: 'ตำบล/แขวง',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    // Subdistrict is optional
                    return null;
                  },
                ),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchSubdistricts,
                  child: const Text('ค้นหา'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ข้อมูลติดต่อ',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            enabled: _canEdit,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'เบอร์โทรศัพท์ (ไม่บังคับ)',
              hintText: 'เบอร์โทรศัพท์ (ไม่บังคับ)',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(Icons.phone),
            ),
            // Phone is optional - no validation required
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            enabled:
                _canEdit &&
                (_authService.currentUser?.isEmployee == true ||
                    _authService.currentUser?.isAdmin == true),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'อีเมล (ไม่บังคับ)',
              hintText: 'อีเมล (ไม่บังคับ)',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              // Email is optional, but if provided must be valid format
              if (value != null && value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถานะ',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<CustomerStatus>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ใช้งาน'),
                  value: CustomerStatus.active,
                  groupValue: _status,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _status = value!;
                          });
                        }
                      : null,
                ),
              ),
              Expanded(
                child: RadioListTile<CustomerStatus>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ไม่ใช้งาน'),
                  value: CustomerStatus.inactive,
                  groupValue: _status,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _status = value!;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineOASection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LINE OA Integration',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('เชื่อมต่อ LINE OA'),
                  value: _isLineConnected,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _isLineConnected = value ?? false;
                          });
                        }
                      : null,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ยืนยันตัวตน'),
                  value: _isVerified,
                  onChanged: _canEdit
                      ? (value) {
                          setState(() {
                            _isVerified = value ?? false;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lineUserIdController,
            enabled: _canEdit,
            decoration: const InputDecoration(
              labelText: 'LINE User ID',
              hintText: 'LINE User ID',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lineDisplayNameController,
            enabled: _canEdit,
            decoration: const InputDecoration(
              labelText: 'LINE Display Name',
              hintText: 'LINE Display Name',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(Icons.badge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'บันทึกเพิ่มเติม',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            enabled: _canEdit,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'บันทึกเพิ่มเติม',
              hintText: 'ข้อมูลเพิ่มเติมหรือหมายเหตุ',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(Icons.note),
            ),
          ),
        ],
      ),
    );
  }
}
