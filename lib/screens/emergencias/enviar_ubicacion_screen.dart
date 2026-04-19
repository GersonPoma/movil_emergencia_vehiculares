import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:auto_sos/services/emergencias/incidente_service.dart';
import 'package:auto_sos/services/emergencias/ubicacion_service.dart';
import 'package:auto_sos/services/emergencias/evidencia_service.dart';
import 'package:auto_sos/services/ia/procesamiento_ia_service.dart';
import 'package:auto_sos/widgets/emergencias/index.dart';
import 'package:auto_sos/models/emergencias/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnviarUbicacionScreen extends StatefulWidget {
  final int usuarioId;
  final String token;

  const EnviarUbicacionScreen({
    super.key,
    required this.usuarioId,
    required this.token,
  });

  @override
  State<EnviarUbicacionScreen> createState() => _EnviarUbicacionScreenState();
}

class _EnviarUbicacionScreenState extends State<EnviarUbicacionScreen> {
  final UbicacionService _ubicacionService = UbicacionService();
  final IncidenteService _incidenteService = IncidenteService();
  final EvidenciaService _evidenciaService = EvidenciaService();
  final ProcesamientoIaService _procesamientoIaService =
      ProcesamientoIaService();

  Position? _ubicacionActual;
  bool _cargando = true;
  bool _enviandoEmergencia = false;
  bool _tienePermiso = false;
  bool _servicioHabilitado = true;
  bool _modoActualizacion = false;
  String? _mensajeUltimoErrorIa;

  Incidente? _incidenteEnviado;
  List<File> _fotos = [];
  File? _audio;
  List<Evidencia> _evidenciasFotosSubidas = [];
  Evidencia? _evidenciaAudioSubida;
  List<String> _rutasFotosSubidas = [];
  String? _rutaAudioSubido;
  int _versionEvidenciaWidget = 0;

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

    if (_fotos.isEmpty && _evidenciasFotosSubidas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes adjuntar al menos una foto.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_audio == null && _evidenciaAudioSubida == null) {
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
      final incidente =
          _incidenteEnviado ??
          await _incidenteService.enviarEmergenciaActual(
            latitud: _ubicacionActual!.latitude,
            longitud: _ubicacionActual!.longitude,
            usuarioId: widget.usuarioId,
            token: widget.token,
          );

      setState(() {
        _incidenteEnviado = incidente;
      });

      if (incidente.id == null) {
        throw Exception('No se pudo obtener el ID del incidente');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modoActualizacion
                  ? 'Reenviando evidencias para análisis...'
                  : 'Subiendo evidencias... ',
            ),
          ),
        );
      }

      await _sincronizarEvidencias(incidente.id!);

      final urlsFotos = _evidenciasFotosSubidas
          .map((e) => e.url)
          .whereType<String>()
          .toList();
      final urlAudio = _evidenciaAudioSubida?.url;

      if (urlsFotos.isEmpty || urlAudio == null || urlAudio.isEmpty) {
        throw Exception('No fue posible preparar todas las evidencias');
      }

      await _procesamientoIaService.procesarEvidencia(
        incidenteId: incidente.id!,
        urlAudio: urlAudio,
        urlsFotos: urlsFotos,
        token: widget.token,
      );

      setState(() {
        _modoActualizacion = false;
        _mensajeUltimoErrorIa = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Incidente enviado y analizado exitosamente!'),
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
    } on ProcesamientoIaException catch (e) {
      await _manejarErrorProcesamientoIa(e);
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

  Future<void> _sincronizarEvidencias(int incidenteId) async {
    if (_evidenciasFotosSubidas.isNotEmpty &&
        !_fotosLocalesCoincidenConSubidas()) {
      await _eliminarFotosSubidas();
    }

    if (_evidenciasFotosSubidas.isEmpty) {
      if (_fotos.isEmpty) {
        throw Exception('Debes adjuntar al menos una foto.');
      }

      final fotosSubidas = <Evidencia>[];
      for (final foto in _fotos) {
        final evidencia = await _evidenciaService.subirYRegistrar(
          archivo: foto,
          tipo: 'Foto',
          incidenteId: incidenteId,
          token: widget.token,
        );
        fotosSubidas.add(evidencia);
      }

      _evidenciasFotosSubidas = fotosSubidas
          .where((e) => e.url != null)
          .toList();
      _rutasFotosSubidas = _fotos.map((f) => f.path).toList();
    }

    if (_evidenciaAudioSubida != null &&
        _audio != null &&
        _rutaAudioSubido != _audio!.path) {
      if (_evidenciaAudioSubida?.id != null) {
        await _evidenciaService.eliminarEvidencia(
          evidenciaId: _evidenciaAudioSubida!.id!,
          token: widget.token,
        );
      }
      _evidenciaAudioSubida = null;
      _rutaAudioSubido = null;
    }

    if (_evidenciaAudioSubida == null) {
      if (_audio == null) {
        throw Exception('Debes grabar un audio antes de enviar.');
      }

      final audioSubido = await _evidenciaService.subirYRegistrar(
        archivo: _audio!,
        tipo: 'Audio',
        incidenteId: incidenteId,
        token: widget.token,
      );

      _evidenciaAudioSubida = audioSubido;
      _rutaAudioSubido = _audio!.path;
    }
  }

  bool _fotosLocalesCoincidenConSubidas() {
    if (_rutasFotosSubidas.length != _fotos.length) {
      return false;
    }

    for (var i = 0; i < _rutasFotosSubidas.length; i++) {
      if (_rutasFotosSubidas[i] != _fotos[i].path) {
        return false;
      }
    }

    return true;
  }

  Future<void> _eliminarFotosSubidas() async {
    for (final foto in _evidenciasFotosSubidas) {
      if (foto.id != null) {
        await _evidenciaService.eliminarEvidencia(
          evidenciaId: foto.id!,
          token: widget.token,
        );
      }
    }
    _evidenciasFotosSubidas = [];
    _rutasFotosSubidas = [];
  }

  Future<void> _manejarErrorProcesamientoIa(ProcesamientoIaException e) async {
    if (e.isAudioInvalido) {
      if (_evidenciaAudioSubida?.id != null) {
        try {
          await _evidenciaService.eliminarEvidencia(
            evidenciaId: _evidenciaAudioSubida!.id!,
            token: widget.token,
          );
        } catch (_) {}
      }

      setState(() {
        _modoActualizacion = true;
        _mensajeUltimoErrorIa =
            'Audio no claro: ${e.message}. Vuelve a grabarlo y reintenta.';
        _evidenciaAudioSubida = null;
        _rutaAudioSubido = null;
        _audio = null;
        _versionEvidenciaWidget++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensajeUltimoErrorIa!),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (e.isImagenInvalida) {
      try {
        await _eliminarFotosSubidas();
      } catch (_) {}

      setState(() {
        _modoActualizacion = true;
        _mensajeUltimoErrorIa =
            'Fotos no claras: ${e.message}. Toma nuevas fotos y reintenta.';
        _fotos = [];
        _versionEvidenciaWidget++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensajeUltimoErrorIa!),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _modoActualizacion = true;
      _mensajeUltimoErrorIa = e.message;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de análisis: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
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
                    if (_modoActualizacion)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Text(
                          _mensajeUltimoErrorIa ??
                              'Modo actualización activo. Ajusta las evidencias y reintenta.',
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
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
                      key: ValueKey(_versionEvidenciaWidget),
                      version: _versionEvidenciaWidget,
                      fotosIniciales: _fotos,
                      audioInicial: _audio,
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
                            : _modoActualizacion
                            ? 'Reenviar Para Analisis'
                            : 'Enviar Emergencia',
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
