import 'package:equatable/equatable.dart';

enum UserRole {
  customer,    // 1. ลูกค้า
  employee,    // 2. ผู้จัดการ และพนักงานขาย รวมเป็น พนักงาน
  admin,       // 3. ผู้ดูแลระบบ
}

class User extends Equatable {
  final String email;
  final String name;
  final UserRole role;
  final bool isLoggedIn;

  const User({
    required this.email,
    required this.name,
    required this.role,
    this.isLoggedIn = false,
  });

  User copyWith({
    String? email,
    String? name,
    UserRole? role,
    bool? isLoggedIn,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [email, name, role, isLoggedIn];
  // Helper methods
  bool get isCustomer => role == UserRole.customer;
  bool get isEmployee => role == UserRole.employee;
  bool get isAdmin => role == UserRole.admin;

  String get roleDisplayName {
    switch (role) {
      case UserRole.customer:
        return 'ลูกค้า';
      case UserRole.employee:
        return 'พนักงาน';
      case UserRole.admin:
        return 'ผู้ดูแลระบบ';
    }
  }
}
