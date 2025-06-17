import 'dart:async';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  User? _currentUser;

  // Stream สำหรับ listen การเปลี่ยนแปลง user state
  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser?.isLoggedIn == true;
  // สำหรับทดสอบ - hardcode users
  Future<bool> login(String email) async {
    User? user;

    switch (email) {
      case 'smltest@gmail.com':
        user = const User(
          email: 'smltest@gmail.com',
          name: 'ลูกค้าทดสอบ',
          role: UserRole.customer,
          isLoggedIn: true,
        );
        break;
      case 'smlstaff@gmail.com':
        user = const User(
          email: 'smlstaff@gmail.com',
          name: 'พนักงานทดสอบ',
          role: UserRole.employee,
          isLoggedIn: true,
        );
        break;
      case 'smladmin@gmail.com':
        user = const User(
          email: 'smladmin@gmail.com',
          name: 'ผู้ดูแลระบบทดสอบ',
          role: UserRole.admin,
          isLoggedIn: true,
        );
        break;
    }

    if (user != null) {
      _currentUser = user;
      _userController.add(_currentUser);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _userController.add(null);
  }

  // สำหรับทดสอบ - สลับ role (1,2,3)
  void switchRole() {
    if (_currentUser != null) {
      UserRole newRole;
      switch (_currentUser!.role) {
        case UserRole.customer:
          newRole = UserRole.employee;
          break;
        case UserRole.employee:
          newRole = UserRole.admin;
          break;
        case UserRole.admin:
          newRole = UserRole.customer;
          break;
      }

      _currentUser = _currentUser!.copyWith(role: newRole);
      _userController.add(_currentUser);
    }
  }

  void dispose() {
    _userController.close();
  }
}
