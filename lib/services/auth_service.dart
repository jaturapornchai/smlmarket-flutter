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

  // สำหรับทดสอบ - hardcode user
  Future<bool> login(String email) async {
    if (email == 'smltest@gmail.com') {
      _currentUser = const User(
        email: 'smltest@gmail.com',
        name: 'ผู้ใช้ทดสอบ',
        role: UserRole.customer,
        isLoggedIn: true,
      );
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
