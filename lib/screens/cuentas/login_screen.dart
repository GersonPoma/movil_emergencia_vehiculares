import 'package:flutter/material.dart';

import '../../models/cuentas/usuario_model.dart';
import '../../services/cuentas/auth_service.dart';
import '../../services/cuentas/storage_service.dart';
import '../../widgets/cuentas/login_widgets.dart';

class LoginCuentasScreen extends StatefulWidget {
  const LoginCuentasScreen({Key? key}) : super(key: key);

  @override
  State<LoginCuentasScreen> createState() => _LoginCuentasScreenState();
}

class _LoginCuentasScreenState extends State<LoginCuentasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valida el formulario y realiza el login
  Future<void> _handleLogin() async {
    // Limpiar error previo
    setState(() => _errorMessage = null);

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Guardar datos de autenticación en SharedPreferences
      await _storageService.saveAuthData(
        token: response.accessToken,
        idUsuario: response.idUsuario,
        idPerfil: response.idPerfil,
        idTaller: response.idTaller,
        rol: response.rol,
        privilegios: response.privilegios,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bienvenido ${response.rol.toUpperCase()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navegar según el rol después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));

        final rol = response.rol.toLowerCase().trim();

        if (rol == 'cliente') {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home_cliente');
          }
        } else if (rol == 'tecnico') {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home_tecnico');
          }
        } else if (rol == 'admin_taller') {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home_admin_taller');
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Header con logo y título
              const LoginHeader(),

              // Formulario de login
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de usuario
                    LoginTextField(
                      label: 'Usuario',
                      hint: 'Ingresa tu usuario',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El usuario es requerido';
                        }
                        if (value.length < 3) {
                          return 'El usuario debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Campo de contraseña
                    LoginTextField(
                      label: 'Contraseña',
                      hint: 'Ingresa tu contraseña',
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Botón de login
                    LoginButton(
                      text: 'INICIAR SESIÓN',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Links adicionales (opcional)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar recuperación de contraseña
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en desarrollo')),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/registro_cliente');
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
