import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;

class ChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 3),
              FlSpot(1, 5),
              FlSpot(2, 4),
              FlSpot(3, 7),
            ],
            isCurved: true,
            color: Colors.blue, // Cambio aquí
          ),
        ],
      ),
    );
  }

  // Convertir el gráfico a imagen
  static Future<pw.MemoryImage> getChartImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Utilizamos RepaintBoundary para capturar la imagen del widget
    final chart = ChartWidget();
    final repaintBoundary = RepaintBoundary(
        child: Container(width: 300, height: 200, child: chart));

    final picture = recorder.endRecording();
    final image = await picture.toImage(300, 200);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return pw.MemoryImage(bytes!.buffer.asUint8List());
  }
}
