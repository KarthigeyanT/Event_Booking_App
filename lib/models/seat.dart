// models/seat.dart
class Seat {
  final int row;
  final int col;
  final SeatType type;
  bool isSelected;

  Seat({
    required this.row,
    required this.col,
    this.type = SeatType.available,
    this.isSelected = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Seat &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

enum SeatType {
  available,
  reserved,
  selected,
  unavailable,
}