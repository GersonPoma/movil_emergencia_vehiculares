class OrdenServicio {
  final int id;
  final String fechaHora;
  final int tiempoEstimadoLlegadaSegundos;
  final String tiempoEstimadoLlegada;
  final String estado;
  final int asignacionCandidatoId;

  OrdenServicio({
    required this.id,
    required this.fechaHora,
    required this.tiempoEstimadoLlegadaSegundos,
    required this.tiempoEstimadoLlegada,
    required this.estado,
    required this.asignacionCandidatoId,
  });

  factory OrdenServicio.fromJson(Map<String, dynamic> json) {
    return OrdenServicio(
      id: json['id'] as int,
      fechaHora: json['fecha_hora'] as String,
      tiempoEstimadoLlegadaSegundos:
          json['tiempo_estimado_llegada_segundos'] as int,
      tiempoEstimadoLlegada: json['tiempo_estimado_llegada'] as String,
      estado: json['estado'] as String,
      asignacionCandidatoId: json['asignacion_candidato_id'] as int,
    );
  }
}
