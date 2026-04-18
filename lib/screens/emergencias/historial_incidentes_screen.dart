import 'package:flutter/material.dart';
import 'package:auto_sos/services/emergencias/incidente_service.dart';
import 'package:auto_sos/models/emergencias/index.dart';
import 'package:intl/intl.dart';
import 'evidencias_incidente_screen.dart';

class HistorialIncidentesScreen extends StatefulWidget {
  final int usuarioId;
  final String token;

  const HistorialIncidentesScreen({
    Key? key,
    required this.usuarioId,
    required this.token,
  }) : super(key: key);

  @override
  State<HistorialIncidentesScreen> createState() =>
      _HistorialIncidentesScreenState();
}

class _HistorialIncidentesScreenState extends State<HistorialIncidentesScreen> {
  final IncidenteService _incidenteService = IncidenteService();
  List<Incidente> _incidentes = [];
  bool _cargando = true;
  int _paginaActual = 1;
  int _totalPaginas = 1;
  final int _limitePorPagina = 10;

  @override
  void initState() {
    super.initState();
    _cargarIncidentes();
  }

  Future<void> _cargarIncidentes({int pagina = 1}) async {
    setState(() {
      _cargando = true;
    });

    try {
      final resultado = await _incidenteService.obtenerIncidentesUsuario(
        usuarioId: widget.usuarioId,
        token: widget.token,
        pagina: pagina,
        limite: _limitePorPagina,
      );

      setState(() {
        _incidentes = resultado['datos'] as List<Incidente>;
        _paginaActual = resultado['pagina'] as int;
        _totalPaginas = resultado['total_paginas'] as int;
        _cargando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar incidentes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _cargando = false;
      });
    }
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'atendido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _obtenerColorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Incidentes'),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _incidentes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay incidentes reportados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _incidentes.length,
                    itemBuilder: (context, index) {
                      final incidente = _incidentes[index];
                      return _construirTarjetaIncidente(incidente);
                    },
                  ),
                ),
                // Controles de paginación
                if (_totalPaginas > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _paginaActual > 1
                              ? () =>
                                    _cargarIncidentes(pagina: _paginaActual - 1)
                              : null,
                          child: const Text('Anterior'),
                        ),
                        Text(
                          'Página $_paginaActual de $_totalPaginas',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: _paginaActual < _totalPaginas
                              ? () =>
                                    _cargarIncidentes(pagina: _paginaActual + 1)
                              : null,
                          child: const Text('Siguiente'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _confirmarCancelar(Incidente incidente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar incidente'),
        content: Text('¿Seguro que deseas cancelar el incidente #${incidente.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _incidenteService.cancelarIncidente(
        incidenteId: incidente.id!,
        token: widget.token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidente cancelado'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarIncidentes(pagina: _paginaActual);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _construirTarjetaIncidente(Incidente incidente) {
    final formato = DateFormat('dd/MM/yyyy HH:mm');
    final fechaFormato = incidente.fechaHora != null
        ? formato.format(incidente.fechaHora!.toLocal())
        : 'Fecha no disponible';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ID y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${incidente.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  fechaFormato,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ubicación
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${incidente.latitud.toStringAsFixed(4)}, ${incidente.longitud.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Estado y Prioridad
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _obtenerColorEstado(
                        incidente.estado,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _obtenerColorEstado(incidente.estado),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        incidente.estado,
                        style: TextStyle(
                          color: _obtenerColorEstado(incidente.estado),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _obtenerColorPrioridad(
                        incidente.prioridad,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _obtenerColorPrioridad(incidente.prioridad),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Prioridad: ${incidente.prioridad}',
                        style: TextStyle(
                          color: _obtenerColorPrioridad(incidente.prioridad),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 4,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ver ubicación en mapa')),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Ver en Mapa'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EvidenciasIncidenteScreen(
                          incidenteId: incidente.id!,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library, color: Colors.purple),
                  label: const Text(
                    'Evidencias',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                if (incidente.estado.toLowerCase() == 'pendiente')
                  TextButton.icon(
                    onPressed: () => _confirmarCancelar(incidente),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
