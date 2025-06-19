import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'repositories/product_repository.dart';
import 'services/cart_service.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  AppRouter.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(ProductRepository()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(cartService: CartService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'SML Market',
        theme: AppTheme.theme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
