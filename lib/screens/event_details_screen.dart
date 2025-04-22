// screens/event_details_screen.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import 'ticket_selection_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                event.imagePath ?? 'assets/images/event_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, size: 100),
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareEvent(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${event.rating} (${event.views} reviews)',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    text: '${event.date} • ${event.time}',
                  ),
                  _buildDetailRow(
                    icon: Icons.location_on,
                    text: event.venue,
                  ),
                  if (event.location.isNotEmpty) 
                    _buildDetailRow(
                      icon: Icons.map,
                      text: event.location,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'About the Event',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToTicketSelection(context),
                      child: const Text('Book Tickets'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _shareEvent(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event shared!')),
    );
  }

  void _navigateToTicketSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketSelectionScreen(event: event),
      ),
    );
  }
}