# SML Market - Shopee-Style E-commerce App

## 📱 Project Description
แอปพลิเคชัน E-commerce สไตล์ Shopee พัฒนาด้วย Flutter สำหรับระบบค้นหาสินค้าออนไลน์ ระบบตระกร้า และระบบสั่งซื้อสินค้า

### 🚀 Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Windows Desktop
- ✅ macOS
- ✅ Linux
- ✅ Web Browser

## 🎯 Features

### 👥 Customer Side (ระบบฝั่งลูกค้า)
- **ค้นหา**: Product search and browsing functionality
- **ตระกร้าสินค้า**: Shopping cart management with special price requests  
- **ประวัติ**: Order history and tracking
- **โปรไฟล์**: User profile management
- **ตั้งค่า**: Application settings and preferences

### 🛠️ Admin/Staff Side (ระบบฝั่งพนักงาน)
- **Dashboard**: Management dashboard overview
- **รายการสินค้า**: Product management
- **คำสั่งซื้อ**: Order management and processing
- **รายงาน**: Reports and analytics
- **โปรไฟล์**: Staff profile management
- **ตั้งค่า**: System settings

## 🏗️ Technology Stack
- **Frontend**: Flutter 3.32.2 & Dart 3.8.1
- **Backend API**: GoLang
- **Database**: ClickHouse
- **State Management**: BLoC Pattern
- **Routing**: go_router
- **HTTP**: http package
- **Image Loading**: cached_network_image

## 📦 Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  http: ^1.1.0
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  go_router: ^14.2.7
  flutter_staggered_animations: ^1.1.1
  cached_network_image: ^3.3.1
```

## 🌐 API Endpoints
- **Health Check**: `http://0.0.0.0:8008/health`
- **API Base**: `http://0.0.0.0:8008/api`
- **Search**: `http://0.0.0.0:8008/search`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.32.2+
- Dart 3.8.1+
- Git

### Installation
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/smlmarket.git
cd smlmarket

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run -d windows    # Windows Desktop
flutter run -d chrome     # Web Browser
flutter run               # Connected mobile device
```

### Building for Production
```bash
# Web (Release Mode recommended for web)
flutter build web

# Windows Desktop
flutter build windows

# Android
flutter build apk
```

## 📁 Project Structure
```
lib/
├── main.dart
├── blocs/search/          # BLoC for search functionality
├── models/                # Data models
├── pages/                 # UI screens
├── repositories/          # Data layer
├── routes/                # App routing
├── services/              # API services
├── theme/                 # App theming
├── utils/                 # Utility functions
└── widgets/               # Reusable UI components
```

## 🎨 Architecture
- **Clean Architecture** with separation of concerns
- **BLoC Pattern** for state management (search functionality only)
- **Repository Pattern** for data abstraction
- **Responsive Design** for multi-platform support

## 🔧 Development Guidelines
- ✅ Use async/await for API calls
- ✅ BLoC only for search functionality
- ✅ No unnecessary animations for performance
- ✅ Cross-platform compatibility
- ❌ No withOpacity (deprecated)
- ❌ No packages that don't support all platforms

## 🐛 Debugging
- **Web Browser**: Use Release Mode only for optimal performance
- **Desktop**: Debug mode available
- **Mobile**: Debug mode available

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## 📄 License
This project is licensed under the MIT License.

## 📞 Support
For support and questions, please open an issue on GitHub.
