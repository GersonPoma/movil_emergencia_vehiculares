import 'package:flutter/material.dart';

class OrdenEstadoChip extends StatelessWidget {
  final String estado;

  const OrdenEstadoChip({super.key, required this.estado});

  Color _color() {
    switch (estado.toLowerCase()) {
      case 'en camino':
        return Colors.blue;
      case 'diagnosticando':
        return Colors.amber.shade700;
      case 'reparando':
        return Colors.orange;
      case 'finalizando':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _icono() {
    switch (estado.toLowerCase()) {
      case 'en camino':
        return Icons.directions_car;
      case 'diagnosticando':
        return Icons.search;
      case 'reparando':
        return Icons.build;
      case 'finalizando':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icono(), color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            estado,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
