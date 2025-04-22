import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event.dart';
import '../models/seat.dart';

class TicketConfirmationScreen extends StatelessWidget {
  final Event event;
  final List<Seat> selectedSeats;
  final int totalPrice;

  final String ticketId;
  final String bookingDate;

  TicketConfirmationScreen({
    super.key,
    required this.event,
    required this.selectedSeats,
    required this.totalPrice,
  })  : ticketId = 'TICKET${DateTime.now().millisecondsSinceEpoch}',
        bookingDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final seatText = selectedSeats.isNotEmpty
        ? selectedSeats
            .map((s) => 'Row ${s.row + 1}, Seat ${s.col + 1}')
            .join(' • ')
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFF10151C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20.0,
                      offset: const Offset(0, 8.0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Row: Title & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Ticket',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'Confirmed',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Event Banner
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: Image.asset(
                        event.imagePath ?? 'assets/images/event_placeholder.png',
                        height: 180.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Event Name
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    Text(
                      'Ticket ID: $ticketId',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Ticket Information Rows
                    _ticketInfoRow('Date', event.date),
                    _ticketInfoRow('Venue', event.venue),
                    _ticketInfoRow('Seats', seatText),
                    _ticketInfoRow('Booked On', bookingDate),
                    _ticketInfoRow('Total', '₹$totalPrice', isBold: true),
                    const SizedBox(height: 28.0),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4.0),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: ticketId,
                        version: QrVersions.auto,
                        size: 200.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Download Ticket
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ticket downloaded as PDF!'),
                            backgroundColor: Colors.deepPurpleAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 20.0),
                      label: const Text('Download Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        elevation: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16.0),
                ),
                child: const Text('← Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.0,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}