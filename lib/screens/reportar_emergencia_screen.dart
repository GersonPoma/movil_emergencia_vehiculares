import 'package:flutter/material.dart';

class ReportarEmergenciaScreen extends StatefulWidget {
  const ReportarEmergenciaScreen({Key? key}) : super(key: key);

  @override
  State<ReportarEmergenciaScreen> createState() =>
      _ReportarEmergenciaScreenState();
}

class _ReportarEmergenciaScreenState extends State<ReportarEmergenciaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Emergencia')),
      body: const Center(child: Text('Pantalla de Reportar Emergencia')),
    );
  }
}
