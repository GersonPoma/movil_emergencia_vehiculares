import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_sos/models/talleres/orden_servicio_model.dart';
import 'package:auto_sos/services/cuentas/storage_service.dart';
import 'package:auto_sos/services/talleres/orden_service.dart';
import 'package:auto_sos/widgets/talleres/orden_estado_chip.dart';

class OrdenServicioScreen extends StatefulWidget {
  final int incidenteId;

  const OrdenServicioScreen({super.key, required this.incidenteId});

  @override
  State<OrdenServicioScreen> createState() => _OrdenServicioScreenState();
}

class _OrdenServicioScreenState extends State<OrdenServicioScreen> {
  final OrdenService _ordenService = OrdenService();
  final StorageService _storageService = StorageService();

  OrdenServicio? _orden;
  bool _cargando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _cargar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargar() async {
    final token = await _storageService.getToken();
    if (token == null) return;

    try {
      final orden = await _ordenService.obtenerPorIncidente(
        widget.incidenteId,
        token,
      );
      if (mounted) {
        setState(() {
          _orden = orden;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatearTiempo(String tiempo) {
    final partes = tiempo.split(':');
    if (partes.length == 3) {
      final horas = int.tryParse(partes[0]) ?? 0;
      final minutos = int.tryParse(partes[1]) ?? 0;
      if (horas > 0) return '$horas h $minutos min';
      if (minutos > 0) return '$minutos min';
      return 'Menos de 1 min';
    }
    return tiempo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Orden de Servicio'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _orden == null
          ? _construirSinOrden()
          : _construirConOrden(),
    );
  }

  Widget _construirSinOrden() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'Tu solicitud está siendo procesada...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Un taller aceptará tu emergencia en breve.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _construirConOrden() {
    final orden = _orden!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.car_repair, size: 56, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  '¡Taller en camino!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Estado
          const Text(
            'Estado actual',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          OrdenEstadoChip(estado: orden.estado),

          const SizedBox(height: 24),

          // Tiempo estimado
          _construirTarjeta(
            icono: Icons.access_time,
            titulo: 'Tiempo estimado de llegada',
            valor: _formatearTiempo(orden.tiempoEstimadoLlegada),
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          // ID orden
          _construirTarjeta(
            icono: Icons.confirmation_number,
            titulo: 'Número de orden',
            valor: '#${orden.id}',
            color: Colors.grey,
          ),

          const SizedBox(height: 24),

          // Actualizando
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Actualizando cada 15 segundos',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirTarjeta({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
