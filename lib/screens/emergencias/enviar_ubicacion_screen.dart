import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:auto_sos/services/emergencias/incidente_service.dart';
import 'package:auto_sos/services/emergencias/ubicacion_service.dart';
import 'package:auto_sos/services/emergencias/evidencia_service.dart';
import 'package:auto_sos/widgets/emergencias/index.dart';
import 'package:auto_sos/models/emergencias/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnviarUbicacionScreen extends StatefulWidget {
  final int usuarioId;
  final String token;

  const EnviarUbicacionScreen({
    Key? key,
    required this.usuarioId,
    required this.token,
  }) : super(key: key);

  @override
  State<EnviarUbicacionScreen> createState() => _EnviarUbicacionScreenState();
}

class _EnviarUbicacionScreenState extends State<EnviarUbicacionScreen> {
  final UbicacionService _ubicacionService = UbicacionService();
  final IncidenteService _incidenteService = IncidenteService();
  final EvidenciaService _evidenciaService = EvidenciaService();

  Position? _ubicacionActual;
  bool _cargando = true;
  bool _enviandoEmergencia = false;
  bool _tienePermiso = false;
  bool _servicioHabilitado = true;
  Incidente? _incidenteEnviado;
  List<File> _fotos = [];
  File? _audio;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _verificarPermisos();
    await _verificarServicio();
    if (_tienePermiso && _servicioHabilitado) {
      await _cargarUbicacion();
    }
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _verificarPermisos() async {
    final tienePermiso = await _ubicacionService.verificarPermiso();
    setState(() {
      _tienePermiso = tienePermiso;
    });
  }

  Future<void> _verificarServicio() async {
    final habilitado = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _servicioHabilitado = habilitado;
    });
  }

  Future<void> _cargarUbicacion() async {
    try {
      final position = await _ubicacionService.obtenerUbicacionActual();
      setState(() {
        _ubicacionActual = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _solicitarPermiso() async {
    final concedido = await _ubicacionService.solicitarPermiso();
    if (concedido) {
      await _cargarUbicacion();
    }
    setState(() {
      _tienePermiso = concedido;
    });
  }

  Future<void> _habilitarServicio() async {
    await _ubicacionService.habilitarServicios();
    await _verificarServicio();
  }

  Future<void> _enviarEmergencia() async {
    if (_ubicacionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se tiene ubicación. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes adjuntar al menos una foto.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_audio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes grabar un audio antes de enviar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _enviandoEmergencia = true);

    try {
      // 1. Crear el incidente
      final incidente = await _incidenteService.enviarEmergenciaActual(
        latitud: _ubicacionActual!.latitude,
        longitud: _ubicacionActual!.longitude,
        usuarioId: widget.usuarioId,
        token: widget.token,
      );

      setState(() => _incidenteEnviado = incidente);

      // 2. Subir evidencias (fotos y audio) en paralelo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subiendo evidencias...')),
        );
      }

      final tareas = <Future>[
        for (final foto in _fotos)
          _evidenciaService.subirYRegistrar(
            archivo: foto,
            tipo: 'Foto',
            incidenteId: incidente.id!,
            token: widget.token,
          ),
        _evidenciaService.subirYRegistrar(
          archivo: _audio!,
          tipo: 'Audio',
          incidenteId: incidente.id!,
          token: widget.token,
        ),
      ];

      await Future.wait(tareas, eagerError: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Emergencia enviada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('ultima_emergencia_id', incidente.id ?? 0);
        await prefs.setString(
          'ultima_emergencia_hora',
          DateTime.now().toIso8601String(),
        );
      }

      if (mounted) _mostrarDialogoConfirmacion(incidente);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar emergencia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _enviandoEmergencia = false);
    }
  }

  void _mostrarDialogoConfirmacion(Incidente incidente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Emergencia Enviada!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu emergencia ha sido reportada exitosamente.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _construirFilaInfo('ID de Emergencia:', '#${incidente.id}'),
              const SizedBox(height: 8),
              _construirFilaInfo(
                'Ubicación:',
                '${incidente.latitud.toStringAsFixed(4)}, ${incidente.longitud.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 8),
              _construirFilaInfo('Estado:', incidente.estado),
              const SizedBox(height: 16),
              const Text(
                'Los servicios de emergencia han sido notificados.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _construirFilaInfo(String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(valor, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Emergencia'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red.shade600,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Indicadores de estado
                    IndicadorPermisos(
                      tienePermiso: _tienePermiso,
                      servicioHabilitado: _servicioHabilitado,
                      onSolicitarPermiso: _solicitarPermiso,
                      onHabilitarServicio: _habilitarServicio,
                    ),
                    const SizedBox(height: 16),

                    // Mapa
                    if (_tienePermiso && _servicioHabilitado)
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: MapaWidget(
                          latitud: _ubicacionActual?.latitude,
                          longitud: _ubicacionActual?.longitude,
                        ),
                      )
                    else
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Habilita permisos y el servicio\nde ubicación para ver el mapa',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Información de ubicación
                    if (_ubicacionActual != null)
                      TarjetaUbicacion(
                        latitud: _ubicacionActual!.latitude,
                        longitud: _ubicacionActual!.longitude,
                        direccion:
                            'Precisión: ${_ubicacionActual!.accuracy.toStringAsFixed(2)}m',
                      ),
                    const SizedBox(height: 20),

                    // Evidencias (fotos y audio)
                    EvidenciaCapturaWidget(
                      onFotosChanged: (fotos) => setState(() => _fotos = fotos),
                      onAudioChanged: (audio) => setState(() => _audio = audio),
                    ),
                    const SizedBox(height: 20),

                    // Botón de emergencia
                    if (_tienePermiso && _servicioHabilitado)
                      BotoEmergencia(
                        onPressed: _enviarEmergencia,
                        cargando: _enviandoEmergencia,
                        etiqueta: _enviandoEmergencia
                            ? 'Enviando...'
                            : 'Enviar Emergencia',
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
