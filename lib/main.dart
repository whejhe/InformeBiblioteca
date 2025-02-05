import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:informe_biblioteca/services/pdf_service.dart';
import 'package:informe_biblioteca/models/book.dart';

/// Punto de entrada de la aplicación Informe Biblioteca.
///
/// Esta aplicación permite generar informes PDF con información
/// sobre libros prestados por un usuario.
void main() => runApp(MyApp());

/// Widget raíz de la aplicación.
///
/// Este widget configura el tema y el título de la aplicación.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Informe Biblioteca',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

/// Pantalla principal de la aplicación.
///
/// Permite al usuario ingresar su nombre y generar un informe PDF
/// con los libros prestados.
class HomeScreen extends StatelessWidget {
  final _chartKey = GlobalKey();
  final TextEditingController _userController =
      TextEditingController(text: "Carlos Fernández");
  final List<Book> _books = [
    Book(
      id: "B-001",
      title: "El Quijote",
      returnDate: DateTime(2024, 3, 15),
      checkoutDate: DateTime(2024, 2, 10),
    ),
    Book(
      id: "B-002",
      title: "Cien años de soledad",
      returnDate: DateTime(2024, 3, 20),
      checkoutDate: DateTime(2024, 6, 10),
    ),
  ];

  List<FlSpot> _generateChartData() {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(Duration(days: 30));
    Map<DateTime, int> booksPerDay = {};

    // Contar libros prestados por día
    for (var book in _books) {
      if (book.checkoutDate.isAfter(oneMonthAgo)) {
        final day = DateTime(book.checkoutDate.year, book.checkoutDate.month,
            book.checkoutDate.day);
        booksPerDay[day] = (booksPerDay[day] ?? 0) + 1;
      }
    }

    return booksPerDay.entries.map((entry) {
      final daysFromStart = entry.key.difference(oneMonthAgo).inDays;
      return FlSpot(daysFromStart.toDouble(), entry.value.toDouble());
    }).toList();
  }

  // Variable para controlar la visibilidad del gráfico
  bool _isChartVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Informe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(/*...*/),
            const SizedBox(height: 20),
            // Gráfico visible solo durante la captura
          RepaintBoundary(
            key: _chartKey,
            child: Opacity(
              opacity: _isChartVisible ? 1.0 : 0.0,
              child: Container(
                width: 400,
                height: 200,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateChartData(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(colors: [
                            Colors.blue,
                            const Color.fromARGB(255, 188, 199, 42)
                          ]),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final boundary = _chartKey.currentContext?.findRenderObject()
                    as RenderRepaintBoundary?;
                if (boundary == null) return;

                final image = await boundary.toImage();
                final byteData =
                    await image.toByteData(format: ImageByteFormat.png);
                final imageBytes = byteData?.buffer.asUint8List();

                if (imageBytes != null) {
                  PdfService.generateReport(
                    userName: _userController.text,
                    books: _books,
                    context: context,
                    chartImageBytes: imageBytes,
                  );
                }
              },
              child: const Text('Generar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
