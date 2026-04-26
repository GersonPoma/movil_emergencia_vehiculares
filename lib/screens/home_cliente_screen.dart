import 'package:flutter/material.dart';

import '../services/cuentas/storage_service.dart';
import '../services/emergencias/incidente_service.dart';
import 'emergencias/enviar_ubicacion_screen.dart';
import 'emergencias/historial_incidentes_screen.dart';
import 'talleres/orden_servicio_screen.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({Key? key}) : super(key: key);

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  final _storageService = StorageService();
  String? _username;
  String? _rol;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final rol = await _storageService.getRol();
    setState(() => _rol = rol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoSOS - Cliente'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: const Text('Perfil'),
                onTap: () {
                  // TODO: Navegar a perfil
                },
              ),
              PopupMenuItem(
                child: const Text('Cerrar Sesión'),
                onTap: () async {
                  await _storageService.clearSession();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rol: ${_rol?.toUpperCase() ?? "Cargando..."}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Título de secciones
              const Text(
                'Opciones Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Grid de opciones
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Card Mi Vehículo
                  _buildOptionCard(
                    icon: Icons.directions_car,
                    label: 'Mi Vehículo',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).pushNamed('/gestionar_vehiculo');
                    },
                  ),

                  // Card Reportar Emergencia
                  _buildOptionCard(
                    icon: Icons.emergency,
                    label: 'Reportar\nEmergencia',
                    color: Colors.red,
                    onTap: () async {
                      final token = await _storageService.getToken();
                      final usuarioId = await _storageService.getIdUsuario();
                      if (!mounted) return;
                      if (token == null || usuarioId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión no válida')),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EnviarUbicacionScreen(
                            usuarioId: usuarioId,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),

                  // Card Orden de Servicio
                  _buildOptionCard(
                    icon: Icons.build_circle,
                    label: 'Orden de\nServicio',
                    color: Colors.green,
                    onTap: () async {
                      final token = await _storageService.getToken();
                      final usuarioId = await _storageService.getIdUsuario();
                      if (!mounted) return;
                      if (token == null || usuarioId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión no válida')),
                        );
                        return;
                      }
                      final incidente = await IncidenteService()
                          .obtenerActivoPorUsuario(
                            usuarioId: usuarioId,
                            token: token,
                          );
                      if (!mounted) return;
                      if (incidente == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No tienes una emergencia activa.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrdenServicioScreen(
                            incidenteId: incidente.id!,
                          ),
                        ),
                      );
                    },
                  ),

                  // Card Historial
                  _buildOptionCard(
                    icon: Icons.history,
                    label: 'Historial',
                    color: Colors.orange,
                    onTap: () async {
                      final token = await _storageService.getToken();
                      final usuarioId = await _storageService.getIdUsuario();
                      if (!mounted) return;
                      if (token == null || usuarioId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión no válida')),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HistorialIncidentesScreen(
                            usuarioId: usuarioId,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Sección de emergencia rápida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'En Caso de Emergencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: SOS rápido
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡SOS Enviado!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Llamada SOS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget para construir cards de opciones
  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
