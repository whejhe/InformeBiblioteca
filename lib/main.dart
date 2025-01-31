import 'package:flutter/material.dart';
import 'package:informe_biblioteca/models/book.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'services/pdf_service.dart';

void main() => runApp(MyApp());

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

class HomeScreen extends StatelessWidget {
  final TextEditingController _userController = TextEditingController(text: "Juan Pérez");
  final List<Book> _books = [
    Book(id: "B-001", title: "El Quijote", returnDate: DateTime(2024, 3, 15)),
    Book(id: "B-002", title: "Cien años de soledad", returnDate: DateTime(2024, 3, 20)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Informe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Nombre del usuario'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => PdfService.generateReport(
                userName: _userController.text,
                books: _books,
              ),
              child: const Text('Generar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}