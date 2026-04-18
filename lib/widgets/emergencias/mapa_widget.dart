import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaWidget extends StatefulWidget {
  final double? latitud;
  final double? longitud;
  final Function(double, double)? onUbicacionSeleccionada;
  final bool permitirSeleccionar;

  const MapaWidget({
    Key? key,
    this.latitud,
    this.longitud,
    this.onUbicacionSeleccionada,
    this.permitirSeleccionar = false,
  }) : super(key: key);

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _ubicacionActual;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUbicacion();
  }

  Future<void> _cargarUbicacion() async {
    try {
      if (widget.latitud != null && widget.longitud != null) {
        _ubicacionActual = LatLng(widget.latitud!, widget.longitud!);
      } else {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        _ubicacionActual = LatLng(position.latitude, position.longitude);
      }

      _agregarMarcador(_ubicacionActual!);
      _moverMapaAUbicacion(_ubicacionActual!);

      setState(() {
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ubicación: $e')),
        );
      }
    }
  }

  void _agregarMarcador(LatLng ubicacion) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('ubicacion_actual'),
          position: ubicacion,
          infoWindow: const InfoWindow(
            title: 'Mi Ubicación',
            snippet: 'Aquí estoy',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _moverMapaAUbicacion(LatLng ubicacion) async {
    if (_mapController != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: ubicacion, zoom: 18),
        ),
      );
    }
  }

  void _onMapTap(LatLng ubicacion) {
    if (widget.permitirSeleccionar) {
      _agregarMarcador(ubicacion);
      widget.onUbicacionSeleccionada?.call(
        ubicacion.latitude,
        ubicacion.longitude,
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ubicacionActual == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No se pudo obtener la ubicación'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarUbicacion,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _ubicacionActual!,
          zoom: 18,
        ),
        markers: _markers,
        onTap: _onMapTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
      ),
    );
  }
}
