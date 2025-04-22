import 'dart:math';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/seat.dart';
import 'ticket_confirmation_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  const TicketSelectionScreen({super.key, required this.event});

  final Event event;

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final int _maxSeats = 6;
  late List<List<Seat>> _seats;
  int _selectedSeatCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    final random = Random();
    _seats = List.generate(10, (row) {
      return List.generate(10, (col) {
        final seatType = random.nextInt(10) < 2
            ? SeatType.reserved
            : random.nextInt(10) < 1
                ? SeatType.unavailable
                : SeatType.available;
        return Seat(row: row, col: col, type: seatType);
      });
    });
  }

  void _toggleSeat(Seat seat) {
    if (seat.type != SeatType.available) return;

    setState(() {
      if (seat.isSelected) {
        seat.isSelected = false;
        _selectedSeatCount--;
      } else if (_selectedSeatCount < _maxSeats) {
        seat.isSelected = true;
        _selectedSeatCount++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can select a maximum of $_maxSeats seats'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        );
      }
    });
  }

  Color _getSeatColor(Seat seat) {
    final theme = Theme.of(context);
    switch (seat.type) {
      case SeatType.available:
        return seat.isSelected
            ? Colors.green // Changed to green for selected seats
            : theme.colorScheme.surface;
      case SeatType.reserved:
        return theme.colorScheme.surfaceContainerHighest;
      case SeatType.unavailable:
        return theme.colorScheme.errorContainer;
      case SeatType.selected:
        return Colors.green.withOpacity(0.7); // Ensure consistency with green
    }
    return theme.colorScheme.surface; // fallback
  }

  Color _getSeatBorderColor(Seat seat) {
    final theme = Theme.of(context);
    switch (seat.type) {
      case SeatType.available:
        return seat.isSelected
            ? Colors.green // Match border to green when selected
            : theme.colorScheme.outline;
      default:
        return Colors.transparent;
    }
  }

  IconData? _getSeatIcon(Seat seat) {
    switch (seat.type) {
      case SeatType.reserved:
        return Icons.lock;
      case SeatType.unavailable:
        return Icons.block;
      default:
        return null;
    }
  }

  void _confirmBooking() {
    final selectedSeats = _seats
        .expand((row) => row)
        .where((seat) => seat.isSelected)
        .toList();

    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one seat'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => TicketConfirmationScreen(
          event: widget.event,
          selectedSeats: selectedSeats,
          totalPrice: selectedSeats.length * 500,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
          margin: const EdgeInsets.only(right: 8.0),
        ),
        Text(label, style: const TextStyle(fontSize: 14.0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Select Seats for ${widget.event.name}',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Seat Legend (Removed "Available")
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.green, 'Selected'), // Changed to green
                _buildLegendItem(colorScheme.surfaceContainerHighest, 'Reserved'),
                _buildLegendItem(colorScheme.errorContainer, 'Unavailable'),
              ],
            ),
          ),

          // Stage Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2.0),
                ),
              ],
            ),
            child: Text(
              'STAGE',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // Seat Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  final row = index ~/ 10;
                  final col = index % 10;
                  final seat = _seats[row][col];

                  return GestureDetector(
                    onTap: () => _toggleSeat(seat),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSeatColor(seat),
                        border: Border.all(
                          color: _getSeatBorderColor(seat),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2.0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _getSeatIcon(seat) != null
                            ? Icon(
                                _getSeatIcon(seat),
                                size: 14.0,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : Text(
                                '${row + 1}-${col + 1}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: seat.type == SeatType.available
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                semanticsLabel: 'Row ${row + 1}, Seat ${col + 1}',
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
         ),

          // Booking Summary
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: const Offset(0, -2.0),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: $_selectedSeatCount seats',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}