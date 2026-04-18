import 'package:flutter/material.dart';

class BotoEmergencia extends StatefulWidget {
  final VoidCallback onPressed;
  final bool cargando;
  final String? etiqueta;

  const BotoEmergencia({
    Key? key,
    required this.onPressed,
    this.cargando = false,
    this.etiqueta = 'Enviar Emergencia',
  }) : super(key: key);

  @override
  State<BotoEmergencia> createState() => _BotoEmergenciaState();
}

class _BotoEmergenciaState extends State<BotoEmergencia> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: widget.cargando ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: widget.cargando
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.warning_rounded, size: 28),
        label: Text(
          widget.etiqueta ?? 'Enviar Emergencia',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TarjetaUbicacion extends StatelessWidget {
  final double latitud;
  final double longitud;
  final String? direccion;
  final VoidCallback? onVerEnMapa;

  const TarjetaUbicacion({
    Key? key,
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.onVerEnMapa,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación Actual',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$latitud, $longitud',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (direccion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      direccion!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onVerEnMapa != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onVerEnMapa,
                icon: const Icon(Icons.map),
                label: const Text('Ver en Mapa'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class IndicadorPermisos extends StatelessWidget {
  final bool tienePermiso;
  final bool servicioHabilitado;
  final VoidCallback? onSolicitarPermiso;
  final VoidCallback? onHabilitarServicio;

  const IndicadorPermisos({
    Key? key,
    required this.tienePermiso,
    required this.servicioHabilitado,
    this.onSolicitarPermiso,
    this.onHabilitarServicio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!tienePermiso)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[400]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Se requiere permiso de ubicación',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: onSolicitarPermiso,
                  child: const Text('Permitir'),
                ),
              ],
            ),
          ),
        if (!servicioHabilitado)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[400]!),
            ),
            child: Row(
              children: [
                Icon(Icons.location_off, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Servicio de ubicación deshabilitado',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: onHabilitarServicio,
                  child: const Text('Habilitar'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
