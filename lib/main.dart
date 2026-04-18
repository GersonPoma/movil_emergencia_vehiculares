import 'package:flutter/material.dart';
import 'screens/cuentas/index.dart';
import 'screens/home_cliente_screen.dart';
import 'screens/perfil/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoSOS - Sistema de Emergencias Vehiculares',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginCuentasScreen(),
        '/registro_cliente': (context) => const CrearClienteScreen(),
        '/home_cliente': (context) => const HomeClienteScreen(),
        '/gestionar_vehiculo': (context) => const GestionarVehiculoScreen(),
      },
    );
  }
}
