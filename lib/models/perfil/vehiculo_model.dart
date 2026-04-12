class VehiculoCrear {
  final String placa;
  final String modelo;
  final String color;
  final int clienteId;

  VehiculoCrear({
    required this.placa,
    required this.modelo,
    required this.color,
    required this.clienteId,
  });

  Map<String, dynamic> toJson() => {
    'placa': placa,
    'modelo': modelo,
    'color': color,
    'cliente_id': clienteId,
  };
}

class VehiculoActualizar {
  final String? placa;
  final String? modelo;
  final String? color;

  VehiculoActualizar({this.placa, this.modelo, this.color});

  Map<String, dynamic> toJson() => {
    if (placa != null) 'placa': placa,
    if (modelo != null) 'modelo': modelo,
    if (color != null) 'color': color,
  };
}

class VehiculoSalida {
  final int id;
  final String placa;
  final String modelo;
  final String color;
  final int clienteId;

  VehiculoSalida({
    required this.id,
    required this.placa,
    required this.modelo,
    required this.color,
    required this.clienteId,
  });

  factory VehiculoSalida.fromJson(Map<String, dynamic> json) {
    return VehiculoSalida(
      id: json['id'] as int,
      placa: json['placa'] as String,
      modelo: json['modelo'] as String,
      color: json['color'] as String,
      clienteId: json['cliente_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'placa': placa,
    'modelo': modelo,
    'color': color,
    'cliente_id': clienteId,
  };
}
