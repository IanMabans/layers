import 'package:flutter/material.dart';
import 'package:layers/screens/homescreen.dart';
import 'package:provider/provider.dart';
import 'model/egg_collection_provider.dart';
import 'model/sales_provider.dart'; // Ensure you import this provider
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EggCollectionProvider()..fetchCollections()),
        ChangeNotifierProvider(create: (_) => SalesProvider()), // Added SalesProvider here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Farm App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
