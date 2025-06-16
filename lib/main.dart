import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'repositories/product_repository.dart';
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
    return BlocProvider<SearchBloc>(
      create: (context) => SearchBloc(ProductRepository()),
      child: MaterialApp.router(
        title: 'SML Market',
        theme: AppTheme.theme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
