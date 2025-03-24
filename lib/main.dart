import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  Routes.configureRoutes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Port Security System',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[900]!,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[850],
          elevation: 4,
          margin: const EdgeInsets.all(8),
        ),
      ),
      initialRoute: "/",
      onGenerateRoute: Routes.router.generator,
      debugShowCheckedModeBanner: false,
    );
  }
}
