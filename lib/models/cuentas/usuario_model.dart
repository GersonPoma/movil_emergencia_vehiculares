class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int idUsuario;
  final int? idPerfil; // id_cliente o id_tecnico
  final int? idTaller; // para admin_taller y tecnico
  final String rol;
  final List<String> privilegios;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.idUsuario,
    this.idPerfil,
    this.idTaller,
    required this.rol,
    required this.privilegios,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      idUsuario: json['id_usuario'] as int,
      idPerfil: json['id_perfil'] as int?,
      idTaller: json['id_taller'] as int?,
      rol: json['rol'] as String,
      privilegios: List<String>.from(json['privilegios'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'id_usuario': idUsuario,
    'id_perfil': idPerfil,
    'id_taller': idTaller,
    'rol': rol,
    'privilegios': privilegios,
  };
}

class Usuario {
  final int id;
  final String username;
  final int rolId;

  Usuario({required this.id, required this.username, required this.rolId});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      username: json['username'] as String,
      rolId: json['rol_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'rol_id': rolId,
  };
}
