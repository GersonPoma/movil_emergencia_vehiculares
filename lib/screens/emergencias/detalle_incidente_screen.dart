import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:auto_sos/models/emergencias/incidente_detalle_model.dart';
import 'package:auto_sos/services/emergencias/incidente_service.dart';

class DetalleIncidenteScreen extends StatefulWidget {
  final int incidenteId;
  final String token;

  const DetalleIncidenteScreen({
    super.key,
    required this.incidenteId,
    required this.token,
  });

  @override
  State<DetalleIncidenteScreen> createState() => _DetalleIncidenteScreenState();
}

class _DetalleIncidenteScreenState extends State<DetalleIncidenteScreen> {
  final IncidenteService _service = IncidenteService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  IncidenteDetalle? _detalle;
  bool _cargando = true;
  String? _audioReproduciendoUrl;

  @override
  void initState() {
    super.initState();
    _cargar();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _audioReproduciendoUrl = null);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final detalle = await _service.obtenerDetalle(
        incidenteId: widget.incidenteId,
        token: widget.token,
      );
      if (mounted) setState(() { _detalle = detalle; _cargando = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleAudio(String url) async {
    if (_audioReproduciendoUrl == url) {
      await _audioPlayer.stop();
      setState(() => _audioReproduciendoUrl = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() => _audioReproduciendoUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incidente #${widget.incidenteId}'),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _detalle == null
          ? const Center(child: Text('No se pudo cargar el detalle'))
          : _construirContenido(),
    );
  }

  Widget _construirContenido() {
    final d = _detalle!;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final fotos = d.evidencias.where((e) => e.tipo == 'Foto').toList();
    final audios = d.evidencias.where((e) => e.tipo == 'Audio').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Información del incidente ──
        _seccion(
          icono: Icons.warning_amber_rounded,
          titulo: 'Información del incidente',
          color: Colors.red,
          children: [
            _fila('Estado', d.incidente.estado),
            _fila('Prioridad', d.incidente.prioridad),
            _fila('Fecha', d.incidente.fechaHora != null
                ? fmt.format(d.incidente.fechaHora!.toLocal())
                : '—'),
            _fila('Ubicación',
                '${d.incidente.latitud.toStringAsFixed(5)}, ${d.incidente.longitud.toStringAsFixed(5)}'),
          ],
        ),

        // ── Fotos ──
        if (fotos.isNotEmpty) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.photo_library,
            titulo: 'Fotos (${fotos.length})',
            color: Colors.purple,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fotos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _verFoto(fotos[i].url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(fotos[i].url, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        ],

        // ── Audios ──
        if (audios.isNotEmpty) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.mic,
            titulo: 'Audios (${audios.length})',
            color: Colors.teal,
            children: audios.map((a) {
              final reproduciendo = _audioReproduciendoUrl == a.url;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  reproduciendo ? Icons.stop_circle : Icons.play_circle,
                  color: Colors.teal,
                  size: 36,
                ),
                title: Text('Audio #${a.id}'),
                onTap: () => _toggleAudio(a.url),
              );
            }).toList(),
          ),
        ],

        // ── Análisis IA ──
        if (d.analisis != null) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.psychology,
            titulo: 'Análisis de IA',
            color: Colors.indigo,
            children: [
              if (d.analisis!.categoriaProblema != null)
                _fila('Categoría', d.analisis!.categoriaProblema!),
              if (d.analisis!.daniosIdentificados != null)
                _fila('Daños identificados', d.analisis!.daniosIdentificados!),
              if (d.analisis!.transcripcionAudio != null) ...[
                const SizedBox(height: 8),
                Text('Transcripción',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(d.analisis!.transcripcionAudio!,
                    style: const TextStyle(fontSize: 14)),
              ],
              if (d.analisis!.resumenEstructurado != null) ...[
                const SizedBox(height: 8),
                Text('Resumen',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(d.analisis!.resumenEstructurado!,
                    style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ],

        // ── Taller ──
        if (d.tallerAtendio != null) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.build,
            titulo: 'Taller que atendió',
            color: Colors.blue,
            children: [
              _fila('Nombre', d.tallerAtendio!.nombre),
              if (d.tallerAtendio!.telefono != null)
                _fila('Teléfono', d.tallerAtendio!.telefono!),
              if (d.tallerAtendio!.direccion != null)
                _fila('Dirección', d.tallerAtendio!.direccion!),
            ],
          ),
        ],

        // ── Orden de servicio ──
        if (d.ordenServicio != null) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.receipt_long,
            titulo: 'Orden de servicio',
            color: Colors.orange,
            children: [
              _fila('Estado', d.ordenServicio!.estado),
              _fila('# Orden', '${d.ordenServicio!.id}'),
              if (d.ordenServicio!.detalles.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                ...d.ordenServicio!.detalles.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nombreServicio,
                                style: const TextStyle(fontSize: 14)),
                            if (item.categoria != null)
                              Text(item.categoria!,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                            if (item.comentario != null)
                              Text(item.comentario!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Bs ${item.precioCobrado.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ],

        // ── Transacción / Pago ──
        if (d.transaccion != null) ...[
          const SizedBox(height: 16),
          _seccion(
            icono: Icons.payment,
            titulo: 'Pago',
            color: Colors.green,
            children: [
              _fila('Estado', d.transaccion!.estado),
              _fila('Total', 'Bs ${d.transaccion!.montoCobrado.toStringAsFixed(2)}'),
              if (d.transaccion!.metodoPago != null)
                _fila('Método', d.transaccion!.metodoPago!),
              if (d.transaccion!.fechaHora != null)
                _fila('Fecha', fmt.format(d.transaccion!.fechaHora!.toLocal())),
            ],
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _seccion({
    required IconData icono,
    required String titulo,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Text(titulo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _verFoto(String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: InteractiveViewer(
          child: Center(child: Image.network(url)),
        ),
      ),
    ));
  }
}
