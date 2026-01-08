import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/api.dart';
import 'package:zylix/presentation/screens/welcome.dart';

final GlobalKey<ScaffoldMessengerState> messageKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    // dotenv.load(fileName: '.env'),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  Api.initializeVersion();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messageKey,
      title: 'Zylix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: const WelcomeScreen(),
    );
  }
}
