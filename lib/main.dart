import 'package:dictarchive/providers/dicts_manager.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'screens/home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //(await SharedPreferences.getInstance()).clear();
  runApp(const DictArchive());
}

class DictArchive extends StatelessWidget {
  const DictArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DictsManager>(create: (_) => DictsManager())
        ],
        builder: (context, _) => MaterialApp(
            theme: ThemeData(
                pageTransitionsTheme: const PageTransitionsTheme(builders: {
                  TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal),
                  TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal),
                  TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal)
                }),
                colorSchemeSeed: Colors.deepPurple,
                useMaterial3: true),
            darkTheme: ThemeData(
                pageTransitionsTheme: const PageTransitionsTheme(builders: {
                  TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal),
                  TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal),
                  TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal)
                }),
                brightness: Brightness.dark,
                colorSchemeSeed: Colors.deepPurple,
                useMaterial3: true),
            themeMode: ThemeMode.system,
            home: const HomePage()));
  }
}
