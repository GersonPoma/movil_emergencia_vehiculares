import 'package:flutter/material.dart';

import '../../models/perfil/cliente_model.dart';
import '../../services/perfil/cliente_service.dart';
import '../../widgets/perfil/register_widgets.dart';

class CrearClienteScreen extends StatefulWidget {
  const CrearClienteScreen({Key? key}) : super(key: key);

  @override
  State<CrearClienteScreen> createState() => _CrearClienteScreenState();
}

class _CrearClienteScreenState extends State<CrearClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clienteService = ClienteService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _fechaNacimiento;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Abre el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  /// Valida el formulario y registra el cliente
  Future<void> _handleRegistro() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cliente = await _clienteService.registrarCliente(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fechaNacimiento: _fechaNacimiento,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cliente ${cliente.nombreCompleto} registrado exitosamente',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navegar al login después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
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
      appBar: AppBar(
        title: const Text('Registrar Cliente'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header
              const RegisterHeader(),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nombre
                    RegisterTextField(
                      label: 'Nombre',
                      hint: 'Ej. Juan',
                      controller: _nombreController,
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Apellido
                    RegisterTextField(
                      label: 'Apellido',
                      hint: 'Ej. Pérez',
                      controller: _apellidoController,
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El apellido es requerido';
                        }
                        if (value.length < 2) {
                          return 'El apellido debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Teléfono
                    RegisterTextField(
                      label: 'Teléfono',
                      hint: 'Ej. +1234567890',
                      controller: _telefonoController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El teléfono es requerido';
                        }
                        if (value.length < 7) {
                          return 'El teléfono debe ser válido';
                        }
                        return null;
                      },
                    ),

                    // Email (opcional)
                    RegisterTextField(
                      label: 'Email (Opcional)',
                      hint: 'Ej. juan@example.com',
                      controller: _emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+$',
                          ).hasMatch(value)) {
                            return 'Email inválido';
                          }
                        }
                        return null;
                      },
                    ),

                    // Fecha de Nacimiento (opcional)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _fechaNacimiento == null
                                      ? 'Fecha de Nacimiento (Opcional)'
                                      : 'Nac: ${_fechaNacimiento?.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: _fechaNacimiento == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Usuario
                    RegisterTextField(
                      label: 'Usuario',
                      hint: 'Ej. juan_perez',
                      controller: _usernameController,
                      icon: Icons.account_circle,
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

                    // Contraseña
                    RegisterTextField(
                      label: 'Contraseña',
                      hint: 'Mínimo 6 caracteres',
                      controller: _passwordController,
                      icon: Icons.lock,
                      obscureText: true,
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

                    // Confirmar Contraseña
                    RegisterTextField(
                      label: 'Confirmar Contraseña',
                      hint: 'Repite tu contraseña',
                      controller: _confirmPasswordController,
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debes confirmar la contraseña';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Mostrar error si existe
                    if (_errorMessage != null)
                      Column(
                        children: [
                          ErrorMessageWidget(message: _errorMessage!),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Botón Registrar
                    RegisterButton(
                      text: 'REGISTRAR CLIENTE',
                      isLoading: _isLoading,
                      onPressed: _handleRegistro,
                    ),

                    const SizedBox(height: 20),

                    // Link para volver al login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? '),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Inicia Sesión',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
