import 'package:flutter/material.dart';

import '../../models/perfil/vehiculo_model.dart';
import '../../services/cuentas/storage_service.dart';
import '../../services/perfil/vehiculo_service.dart';
import '../../widgets/perfil/vehiculo_widgets.dart';

class GestionarVehiculoScreen extends StatefulWidget {
  const GestionarVehiculoScreen({Key? key}) : super(key: key);

  @override
  State<GestionarVehiculoScreen> createState() =>
      _GestionarVehiculoScreenState();
}

class _GestionarVehiculoScreenState extends State<GestionarVehiculoScreen> {
  final _vehiculoService = VehiculoService();
  final _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  VehiculoSalida? _vehiculo;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;
  String? _token;
  int? _clienteId;

  // Controllers
  final _placaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehiculo();
  }

  @override
  void dispose() {
    _placaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /// Carga el vehículo del cliente
  Future<void> _loadVehiculo() async {
    _token = await _storageService.getToken();
    _clienteId = await _storageService.getIdPerfil();

    if (_token == null || _clienteId == null) {
      setState(() {
        _errorMessage = 'Error: No hay sesión activa';
        _isLoading = false;
      });
      return;
    }

    try {
      final vehiculo = await _vehiculoService.obtenerPorCliente(
        clienteId: _clienteId!,
        token: _token!,
      );

      setState(() {
        _vehiculo = vehiculo;
        if (vehiculo != null) {
          _placaController.text = vehiculo.placa;
          _modeloController.text = vehiculo.modelo;
          _colorController.text = vehiculo.color;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Abre el formulario de edición/creación
  void _openForm({bool isCreate = false}) {
    setState(() {
      _isEditing = true;
      if (isCreate) {
        _placaController.clear();
        _modeloController.clear();
        _colorController.clear();
      }
    });
  }

  /// Cancela la edición
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
      if (_vehiculo != null) {
        _placaController.text = _vehiculo!.placa;
        _modeloController.text = _vehiculo!.modelo;
        _colorController.text = _vehiculo!.color;
      }
    });
  }

  /// Guarda el vehículo (crear o actualizar)
  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _errorMessage = null);

    try {
      if (_vehiculo == null) {
        // Crear
        final nuevoVehiculo = await _vehiculoService.crear(
          placa: _placaController.text.trim(),
          modelo: _modeloController.text.trim(),
          color: _colorController.text.trim(),
          clienteId: _clienteId!,
          token: _token!,
        );

        setState(() {
          _vehiculo = nuevoVehiculo;
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Actualizar
        final vehiculoActualizado = await _vehiculoService.actualizar(
          clienteId: _clienteId!,
          token: _token!,
          placa: _placaController.text.trim(),
          modelo: _modeloController.text.trim(),
          color: _colorController.text.trim(),
        );

        setState(() {
          _vehiculo = vehiculoActualizado;
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// Elimina el vehículo
  Future<void> _eliminarVehiculo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar Vehículo'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu vehículo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await _vehiculoService.eliminar(
                  clienteId: _clienteId!,
                  token: _token!,
                );

                setState(() {
                  _vehiculo = null;
                  _placaController.clear();
                  _modeloController.clear();
                  _colorController.clear();
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vehículo eliminado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                setState(() {
                  _errorMessage = e.toString().replaceFirst('Exception: ', '');
                });
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Vehículo'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mostrar error si existe
                    if (_errorMessage != null)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Si no está editando y no tiene vehículo
                    if (!_isEditing && _vehiculo == null)
                      EmptyVehicleMessage(
                        onRegister: () => _openForm(isCreate: true),
                      ),

                    // Si no está editando y tiene vehículo
                    if (!_isEditing && _vehiculo != null)
                      Column(
                        children: [
                          VehiculoCard(
                            placa: _vehiculo!.placa,
                            modelo: _vehiculo!.modelo,
                            color: _vehiculo!.color,
                            onEdit: () => _openForm(isCreate: false),
                            onDelete: _eliminarVehiculo,
                          ),
                        ],
                      ),

                    // Si está editando
                    if (_isEditing)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              _vehiculo == null
                                  ? 'Registrar Vehículo'
                                  : 'Editar Vehículo',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Placa
                            VehiculoTextField(
                              label: 'Placa',
                              hint: 'Ej. ABC-1234',
                              controller: _placaController,
                              icon: Icons.directions_car,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La placa es requerida';
                                }
                                if (value.length < 5) {
                                  return 'La placa debe ser válida';
                                }
                                return null;
                              },
                            ),

                            // Modelo
                            VehiculoTextField(
                              label: 'Modelo',
                              hint: 'Ej. Toyota Corolla 2020',
                              controller: _modeloController,
                              icon: Icons.info_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El modelo es requerido';
                                }
                                if (value.length < 3) {
                                  return 'El modelo debe tener al menos 3 caracteres';
                                }
                                return null;
                              },
                            ),

                            // Color
                            VehiculoTextField(
                              label: 'Color',
                              hint: 'Ej. Rojo, Azul, Blanco',
                              controller: _colorController,
                              icon: Icons.palette,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El color es requerido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Botones
                            Row(
                              children: [
                                Expanded(
                                  child: VehiculoButton(
                                    text: 'Cancelar',
                                    onPressed: _cancelEdit,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: VehiculoButton(
                                    text: 'Guardar',
                                    onPressed: _guardarVehiculo,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
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
