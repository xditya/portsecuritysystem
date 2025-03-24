import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';

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
      theme: AppTheme.darkTheme,
      onGenerateRoute: Routes.router.generator,
      initialRoute: '/',
    );
  }
}
