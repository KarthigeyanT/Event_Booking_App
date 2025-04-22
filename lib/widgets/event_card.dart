import 'package:flutter/material.dart';
import '../models/event.dart';
import '../constants/app_constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.cardRadius),
              ),
              child: Image.asset(
                event.imagePath ?? 'assets/images/event_placeholder.png',
                height: AppConstants.imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: AppConstants.imageHeight,
                  color: Colors.grey[200],
                  child: const Icon(Icons.event, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                        onPressed: onToggleBookmark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.venue,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.date,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
