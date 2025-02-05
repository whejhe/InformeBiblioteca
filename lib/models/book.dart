/// Modelo para representar un libro prestado.
///
/// Cada libro tiene un [id], un [title] y una [returnDate]
/// que indica la fecha límite de devolución.
class Book {
  /// Identificador único del libro.
  final String id;

  /// Título del libro.
  final String title;

  /// Fecha de devolución del libro.
  final DateTime returnDate;
  final DateTime checkoutDate;
  /// Constructor del modelo Book.
  ///
  /// @param id El identificador único del libro.
  /// @param title El título del libro.
  /// @param returnDate La fecha de devolución del libro.
  Book({
    required this.id,
    required this.title,
    required this.returnDate,
    required this.checkoutDate,
  });
}