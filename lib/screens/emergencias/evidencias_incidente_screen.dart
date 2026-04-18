import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:auto_sos/models/emergencias/evidencia_model.dart';
import 'package:auto_sos/services/emergencias/evidencia_service.dart';

class EvidenciasIncidenteScreen extends StatefulWidget {
  final int incidenteId;
  final String token;

  const EvidenciasIncidenteScreen({
    Key? key,
    required this.incidenteId,
    required this.token,
  }) : super(key: key);

  @override
  State<EvidenciasIncidenteScreen> createState() =>
      _EvidenciasIncidenteScreenState();
}

class _EvidenciasIncidenteScreenState extends State<EvidenciasIncidenteScreen> {
  final EvidenciaService _service = EvidenciaService();
  final AudioPlayer _player = AudioPlayer();

  List<Evidencia> _fotos = [];
  List<Evidencia> _audios = [];
  bool _cargando = true;
  String? _audioReproduciendoUrl;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _audioReproduciendoUrl = null);
    });
    _cargar();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final evidencias = await _service.obtenerPorIncidente(
        incidenteId: widget.incidenteId,
        token: widget.token,
      );
      setState(() {
        _fotos = evidencias.where((e) => e.tipo == 'Foto').toList();
        _audios = evidencias.where((e) => e.tipo == 'Audio').toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar evidencias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAudio(String url) async {
    if (_audioReproduciendoUrl == url) {
      await _player.stop();
      setState(() => _audioReproduciendoUrl = null);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() => _audioReproduciendoUrl = url);
    }
  }

  void _verFotoCompleta(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VisorFoto(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencias #${widget.incidenteId}'),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (_fotos.isEmpty && _audios.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay evidencias para este incidente',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Fotos ──────────────────────────────────
                  if (_fotos.isNotEmpty) ...[
                    const Text(
                      'Fotos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _fotos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        final foto = _fotos[index];
                        return GestureDetector(
                          onTap: () => _verFotoCompleta(foto.url!),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              foto.url!,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Audios ─────────────────────────────────
                  if (_audios.isNotEmpty) ...[
                    const Text(
                      'Audios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._audios.asMap().entries.map((e) {
                      final audio = e.value;
                      final reproduciendo = _audioReproduciendoUrl == audio.url;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: reproduciendo
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: reproduciendo
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.audiotrack,
                              color: reproduciendo ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Audio ${e.key + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: reproduciendo
                                      ? Colors.blue
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: audio.url != null
                                  ? () => _toggleAudio(audio.url!)
                                  : null,
                              icon: Icon(
                                reproduciendo
                                    ? Icons.stop_circle
                                    : Icons.play_circle,
                                size: 36,
                                color: reproduciendo
                                    ? Colors.blue
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _VisorFoto extends StatelessWidget {
  final String url;
  const _VisorFoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
