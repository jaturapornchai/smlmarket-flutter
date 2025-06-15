# smlmarket

A new Flutter project.

## Getting Started

# SML Market - Flutter BLoC Product Search App

A Flutter application that uses BLoC pattern with MultiBlocProvider for state management and provides a beautiful UI for product search using TF-IDF Vector Similarity API.

## Features

- 🏠 **Beautiful Home Page**: Modern menu interface with gradient cards and intuitive navigation
- 🔍 **Advanced Product Search**: AI-powered search using TF-IDF Vector Similarity
- 📱 **Responsive Design**: Works on mobile, tablet, and web
- 🎯 **BLoC Pattern**: Clean architecture with separated business logic
- 🔄 **Infinite Loading**: Load more products as you scroll
- 🌐 **API Integration**: RESTful API integration with proper error handling

## Architecture

This app follows the BLoC (Business Logic Component) pattern with the following structure:

```
lib/
├── blocs/
│   ├── navigation/
│   │   ├── navigation_bloc.dart
│   │   ├── navigation_event.dart
│   │   └── navigation_state.dart
│   └── search/
│       ├── search_bloc.dart
│       ├── search_event.dart
│       └── search_state.dart
├── models/
│   ├── product.dart
│   ├── search_request.dart
│   └── search_response.dart
├── pages/
│   ├── home_page.dart
│   ├── search_page.dart
│   ├── profile_page.dart
│   ├── settings_page.dart
│   └── main_navigation_page.dart
├── repositories/
│   └── product_repository.dart
└── main.dart
```

## API Integration

The app integrates with the product search API at `http://192.168.2.36:8008/search` with the following features:

### Search Endpoint
```
POST /search
Content-Type: application/json

{
  "query": "oil",
  "limit": 10,
  "offset": 0
}
```

### Response Format
```json
{
  "success": true,
  "message": "Search completed successfully",
  "data": {
    "data": [
      {
        "id": "000123",
        "name": "COIL OEM BENZ SPRINTER",
        "similarity_score": 0.856,
        "metadata": {
          "code": "000123",
          "unit": "ใบ",
          "balance_qty": 2.0,
          "supplier_code": "ซ034"
        }
      }
    ],
    "total_count": 150,
    "query": "coil",
    "duration_ms": 45.2
  }
}
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   cd /path/to/project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For mobile
   flutter run
   ```

## Dependencies

### Main Dependencies
- `flutter_bloc`: ^8.1.3 - State management
- `bloc`: ^8.1.2 - Core BLoC library
- `http`: ^1.1.0 - HTTP requests
- `json_annotation`: ^4.8.1 - JSON serialization annotations
- `equatable`: ^2.0.5 - Value equality

### Dev Dependencies
- `json_serializable`: ^6.7.1 - JSON code generation
- `build_runner`: ^2.4.7 - Code generation runner

## Features Overview

### 🏠 Home Page
- Welcome header with user greeting
- Beautiful gradient search card
- Grid menu with modern card design
- Quick navigation to search functionality

### 🔍 Search Page
- Real-time search with debouncing
- Product cards showing similarity scores
- Infinite scroll pagination
- Loading states and error handling
- Search result statistics

### 📊 Product Information
Each product card displays:
- Product name and code
- Similarity score percentage
- Current stock quantity and unit
- Supplier information

## BLoC Implementation

### NavigationBloc
Manages app navigation state with events:
- `NavigateToHome`
- `NavigateToSearch`
- `NavigateToProfile`
- `NavigateToSettings`

### SearchBloc
Handles product search with events:
- `SearchProductsEvent` - Perform new search
- `LoadMoreProductsEvent` - Load additional results
- `ClearSearchEvent` - Clear search results

## Testing

Run tests with:
```bash
flutter test
```

The project includes:
- Unit tests for models
- BLoC tests for state management
- Widget tests for UI components

## API Configuration

To change the API endpoint, modify the `baseUrl` in:
```dart
// lib/repositories/product_repository.dart
static const String baseUrl = 'http://192.168.2.36:8008';
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.
