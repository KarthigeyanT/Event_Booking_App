import 'package:flutter/material.dart';
import '../models/event.dart';

class VenueBookingScreen extends StatelessWidget {
  final Event event;
  
  const VenueBookingScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${event.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Booking for ${event.name}', style: Theme.of(context).textTheme.headlineSmall),
            Text('Venue: ${event.venue}'),
            Text('Date: ${event.date}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venue booked successfully!')),
                );
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}