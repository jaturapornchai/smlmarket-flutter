import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'repositories/product_repository.dart';
import 'pages/dashboard/home_page_new.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (context) => SearchBloc(ProductRepository()),
      child: MaterialApp(
        title: 'SML Market',
        theme: AppTheme.theme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
