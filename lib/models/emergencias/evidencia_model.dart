class Evidencia {
  final int? id;
  final String tipo;
  final String? url;
  final DateTime fecha;
  final int incidenteId;

  Evidencia({
    this.id,
    required this.tipo,
    this.url,
    required this.fecha,
    required this.incidenteId,
  });

  factory Evidencia.fromJson(Map<String, dynamic> json) {
    return Evidencia(
      id: json['id'] as int?,
      tipo: json['tipo'] as String,
      url: json['url'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      incidenteId: json['incidente_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'url': url,
      'fecha': '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
      'incidente_id': incidenteId,
    };
  }
}
