import 'package:flutter/material.dart';
import 'package:expense_tracker/pages/expense_list.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

var kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 3, 12, 182));
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 9, 169, 213),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: kDarkColorScheme,
          dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.white))),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: kColorScheme,
        useMaterial3: true,
        appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kColorScheme.onPrimaryContainer,
            foregroundColor: kColorScheme.primaryContainer,
            titleTextStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        cardTheme:
            const CardTheme().copyWith(color: kColorScheme.primaryContainer),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: kColorScheme.primaryContainer)),
      ),
      home: const ExpenseListPage(),
      themeMode: ThemeMode.system,
    );
  }
}
