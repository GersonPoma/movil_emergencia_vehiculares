import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class EvidenciaCapturaWidget extends StatefulWidget {
  final Function(List<File>) onFotosChanged;
  final Function(File?) onAudioChanged;

  const EvidenciaCapturaWidget({
    Key? key,
    required this.onFotosChanged,
    required this.onAudioChanged,
  }) : super(key: key);

  @override
  State<EvidenciaCapturaWidget> createState() => _EvidenciaCapturaWidgetState();
}

class _EvidenciaCapturaWidgetState extends State<EvidenciaCapturaWidget> {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  List<File> _fotos = [];
  File? _audio;
  bool _grabando = false;
  bool _reproduciendo = false;

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setAudioContext(
      const AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [AVAudioSessionOptions.defaultToSpeaker],
        ),
      ),
    );
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _reproduciendo = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _mostrarSnackbarAjustes(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        action: SnackBarAction(label: 'Ajustes', onPressed: openAppSettings),
      ),
    );
  }

  Future<void> _tomarFoto() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (foto == null) return;
      setState(() => _fotos = [..._fotos, File(foto.path)]);
      widget.onFotosChanged(_fotos);
    } catch (e) {
      _mostrarSnackbarAjustes(
        'No se pudo abrir la cámara. Revisa los permisos en Ajustes.',
      );
    }
  }

  void _eliminarFoto(int index) {
    setState(() => _fotos = [..._fotos]..removeAt(index));
    widget.onFotosChanged(_fotos);
  }

  Future<void> _iniciarGrabacion() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _mostrarSnackbarAjustes(
        'Permiso de micrófono denegado. Actívalo en Ajustes.',
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _grabando = true;
      _audio = null;
    });
    widget.onAudioChanged(null);
  }

  Future<void> _detenerGrabacion() async {
    final path = await _recorder.stop();
    setState(() {
      _grabando = false;
      if (path != null) _audio = File(path);
    });
    widget.onAudioChanged(_audio);
  }

  Future<void> _toggleReproduccion() async {
    if (_audio == null) return;
    if (_reproduciendo) {
      await _player.stop();
      setState(() => _reproduciendo = false);
    } else {
      await _player.play(DeviceFileSource(_audio!.path));
      setState(() => _reproduciendo = true);
    }
  }

  Future<void> _eliminarAudio() async {
    await _player.stop();
    setState(() {
      _audio = null;
      _reproduciendo = false;
    });
    widget.onAudioChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final colorEsquema = Theme.of(context).colorScheme;
    final textoSecundario =
        Theme.of(context).textTheme.bodySmall?.color ??
        colorEsquema.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorEsquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorEsquema.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidencias',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorEsquema.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // ── Fotos ──────────────────────────────────────────
          Text(
            'Fotos',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _BotonAgregarFoto(onTap: _tomarFoto),
                ..._fotos.asMap().entries.map(
                  (e) => _MiniaturFoto(
                    foto: e.value,
                    onEliminar: () => _eliminarFoto(e.key),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Audio ──────────────────────────────────────────
          Text(
            'Audio',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 8),

          if (_audio == null)
            ElevatedButton.icon(
              onPressed: _grabando ? _detenerGrabacion : _iniciarGrabacion,
              icon: Icon(_grabando ? Icons.stop : Icons.mic),
              label: Text(_grabando ? 'Detener grabación' : 'Grabar audio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _grabando ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Audio grabado',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Botón play/pause
                  IconButton(
                    onPressed: _toggleReproduccion,
                    icon: Icon(
                      _reproduciendo ? Icons.stop_circle : Icons.play_circle,
                      color: Colors.blue,
                      size: 32,
                    ),
                    tooltip: _reproduciendo ? 'Detener' : 'Escuchar',
                  ),
                  // Botón eliminar
                  IconButton(
                    onPressed: _eliminarAudio,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar audio',
                  ),
                ],
              ),
            ),

          if (_grabando)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Grabando...',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonAgregarFoto extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonAgregarFoto({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade50,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.blue, size: 28),
            SizedBox(height: 4),
            Text('Foto', style: TextStyle(color: Colors.blue, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MiniaturFoto extends StatelessWidget {
  final File foto;
  final VoidCallback onEliminar;
  const _MiniaturFoto({required this.foto, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(foto, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: onEliminar,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
