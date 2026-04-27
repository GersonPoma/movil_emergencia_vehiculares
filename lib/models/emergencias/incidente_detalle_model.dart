class IncidenteDetalle {
  final IncidenteResumen incidente;
  final List<EvidenciaResumen> evidencias;
  final AnalisisResumen? analisis;
  final TallerResumen? tallerAtendio;
  final OrdenResumen? ordenServicio;
  final TransaccionResumen? transaccion;

  IncidenteDetalle({
    required this.incidente,
    required this.evidencias,
    this.analisis,
    this.tallerAtendio,
    this.ordenServicio,
    this.transaccion,
  });

  factory IncidenteDetalle.fromJson(Map<String, dynamic> json) {
    return IncidenteDetalle(
      incidente: IncidenteResumen.fromJson(json['incidente']),
      evidencias: (json['evidencias'] as List? ?? [])
          .map((e) => EvidenciaResumen.fromJson(e))
          .toList(),
      analisis: json['analisis'] != null
          ? AnalisisResumen.fromJson(json['analisis'])
          : null,
      tallerAtendio: json['taller_atendio'] != null
          ? TallerResumen.fromJson(json['taller_atendio'])
          : null,
      ordenServicio: json['orden_servicio'] != null
          ? OrdenResumen.fromJson(json['orden_servicio'])
          : null,
      transaccion: json['transaccion'] != null
          ? TransaccionResumen.fromJson(json['transaccion'])
          : null,
    );
  }
}

class IncidenteResumen {
  final int id;
  final double latitud;
  final double longitud;
  final String estado;
  final String prioridad;
  final DateTime? fechaHora;

  IncidenteResumen({
    required this.id,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.prioridad,
    this.fechaHora,
  });

  factory IncidenteResumen.fromJson(Map<String, dynamic> json) {
    return IncidenteResumen(
      id: json['id'] as int,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      estado: json['estado'] as String,
      prioridad: json['prioridad'] as String,
      fechaHora: json['fecha_hora'] != null
          ? DateTime.tryParse(json['fecha_hora'].toString())
          : null,
    );
  }
}

class EvidenciaResumen {
  final int id;
  final String url;
  final String tipo;
  final DateTime? fechaSubida;

  EvidenciaResumen({
    required this.id,
    required this.url,
    required this.tipo,
    this.fechaSubida,
  });

  factory EvidenciaResumen.fromJson(Map<String, dynamic> json) {
    return EvidenciaResumen(
      id: json['id'] as int,
      url: json['url'] as String,
      tipo: json['tipo'] as String,
      fechaSubida: json['fecha_subida'] != null
          ? DateTime.tryParse(json['fecha_subida'].toString())
          : null,
    );
  }
}

class AnalisisResumen {
  final int id;
  final String? transcripcionAudio;
  final String? categoriaProblema;
  final String? daniosIdentificados;
  final String? resumenEstructurado;

  AnalisisResumen({
    required this.id,
    this.transcripcionAudio,
    this.categoriaProblema,
    this.daniosIdentificados,
    this.resumenEstructurado,
  });

  factory AnalisisResumen.fromJson(Map<String, dynamic> json) {
    return AnalisisResumen(
      id: json['id'] as int,
      transcripcionAudio: json['transcripcion_audio'] as String?,
      categoriaProblema: json['categoria_problema'] as String?,
      daniosIdentificados: json['danios_identificados'] as String?,
      resumenEstructurado: json['resumen_estructurado'] as String?,
    );
  }
}

class TallerResumen {
  final int id;
  final String nombre;
  final String? telefono;
  final String? direccion;

  TallerResumen({
    required this.id,
    required this.nombre,
    this.telefono,
    this.direccion,
  });

  factory TallerResumen.fromJson(Map<String, dynamic> json) {
    return TallerResumen(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
    );
  }
}

class DetalleOrdenItem {
  final int id;
  final String nombreServicio;
  final String? categoria;
  final double precioCobrado;
  final String? comentario;

  DetalleOrdenItem({
    required this.id,
    required this.nombreServicio,
    this.categoria,
    required this.precioCobrado,
    this.comentario,
  });

  factory DetalleOrdenItem.fromJson(Map<String, dynamic> json) {
    return DetalleOrdenItem(
      id: json['id'] as int,
      nombreServicio: json['nombre_servicio'] as String? ?? 'Desconocido',
      categoria: json['categoria'] as String?,
      precioCobrado: (json['precio_cobrado'] as num).toDouble(),
      comentario: json['comentario'] as String?,
    );
  }
}

class OrdenResumen {
  final int id;
  final String estado;
  final int? tiempoEstimadoSegundos;
  final DateTime? fechaHora;
  final List<DetalleOrdenItem> detalles;

  OrdenResumen({
    required this.id,
    required this.estado,
    this.tiempoEstimadoSegundos,
    this.fechaHora,
    required this.detalles,
  });

  factory OrdenResumen.fromJson(Map<String, dynamic> json) {
    return OrdenResumen(
      id: json['id'] as int,
      estado: json['estado'] as String,
      tiempoEstimadoSegundos: json['tiempo_estimado_segundos'] as int?,
      fechaHora: json['fecha_hora'] != null
          ? DateTime.tryParse(json['fecha_hora'].toString())
          : null,
      detalles: (json['detalles'] as List? ?? [])
          .map((d) => DetalleOrdenItem.fromJson(d))
          .toList(),
    );
  }
}

class TransaccionResumen {
  final int id;
  final double montoCobrado;
  final double? montoComision;
  final String estado;
  final String? metodoPago;
  final DateTime? fechaHora;

  TransaccionResumen({
    required this.id,
    required this.montoCobrado,
    this.montoComision,
    required this.estado,
    this.metodoPago,
    this.fechaHora,
  });

  factory TransaccionResumen.fromJson(Map<String, dynamic> json) {
    return TransaccionResumen(
      id: json['id'] as int,
      montoCobrado: (json['monto_cobrado'] as num).toDouble(),
      montoComision: json['monto_comision'] != null
          ? (json['monto_comision'] as num).toDouble()
          : null,
      estado: json['estado'] as String,
      metodoPago: json['metodo_pago'] as String?,
      fechaHora: json['fecha_hora'] != null
          ? DateTime.tryParse(json['fecha_hora'].toString())
          : null,
    );
  }
}
