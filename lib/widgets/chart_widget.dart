import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

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
            colors: [Colors.blue],
          ),
        ],
      ),
    );
  }

  // Convertir el gráfico a imagen
  static Future<pw.Image> getChartImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final chart = ChartWidget();
    final widget = Container(width: 300, height: 200, child: chart);
    final renderObject = widget.createRenderObject(context);
    renderObject.layout(constraints);
    renderObject.paint(canvas, Offset.zero);
    final image = await recorder.endRecording().toImage(300, 200);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return pw.MemoryImage(bytes!.buffer.asUint8List());
  }
}