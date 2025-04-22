import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/auth_service.dart';


class AppConstants {
  static const double padding = 20.0;
  static const double cardRadius = 24.0;
  static const double imageHeight = 200.0;
  static const double categoryCardHeight = 100.0;
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFF00CEFF),
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF636E72)),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF636E72)),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showSearchBar = false;
  bool _isLoading = true;
  final List<Event> _bookings = [];

  void _navigateToTicketScreen(BuildContext context, Event event) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => TicketScreen(event: event),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100 && !_showSearchBar) {
      setState(() => _showSearchBar = true);
    } else if (_scrollController.position.pixels <= 100 && _showSearchBar) {
      setState(() => _showSearchBar = false);
    }
  }

  void _togglePlan(Event event) {
    setState(() {
      if (_bookings.any((e) => e.id == event.id)) {
        _bookings.removeWhere((e) => e.id == event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${event.name} from plan'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        _bookings.add(event);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${event.name} to plan'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    });
  }

  List<Event> get _filteredEvents {
    return events.where((event) {
      final matchesSearch = event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.venue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.date.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || event.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: const EdgeInsets.only(
                    left: AppConstants.padding,
                    right: AppConstants.padding,
                    top: kToolbarHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        opacity: _showSearchBar ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover Events',
                              style: theme.textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find the best events in your city',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _showSearchBar ? 0 : 56,
                        child: Hero(
                          tag: 'search',
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Search events...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () => AuthService.signOut(),
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            SizedBox(
              height: AppConstants.categoryCardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
                itemCount: _isLoading ? 5 : categories.length,
                itemBuilder: (context, index) {
                  if (_isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                          ),
                        ),
                      ),
                    );
                  }
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category.name);
                      _tabController.animateTo(0);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        color: _selectedCategory == category.name
                            ? colorScheme.primary.withAlpha((0.1 * 255).toInt())
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                        border: _selectedCategory == category.name
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category.icon, size: 30, color: colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _selectedCategory == category.name
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Material(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Featured'),
                  Tab(text: 'Popular'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Nearby'),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
                indicatorColor: colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
                isScrollable: true,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (index) {
                    final filteredEvents = _isLoading
                        ? List.generate(3, (i) => events[0])
                        : _filteredEvents;

                    if (_isLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.padding),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 60, color: colorScheme.onSurface.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  'No events found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppConstants.padding),
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, eventIndex) {
                              final event = filteredEvents[eventIndex];
                              final isBookmarked = _bookings.any((e) => e.id == event.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: EventCard(
                                  event: event,
                                  isBookmarked: isBookmarked,
                                  onToggleBookmark: () => _togglePlan(event),
                                  onTap: () => _navigateToTicketScreen(context, event),
                                ),
                              );
                            },
                          );
                  }),
                ),
              ),
            ),
            if (_bookings.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.padding,
                  16,
                  AppConstants.padding,
                  AppConstants.padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Plan',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_bookings.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final event = _bookings[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: PlanCard(event: event),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.map, color: Colors.white),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
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
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isBookmarked) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBookmarked != oldWidget.isBookmarked) {
      if (widget.isBookmarked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.cardRadius),
                    ),
                    child: widget.event.imagePath.isNotEmpty
                        ? Image.asset(
                            widget.event.imagePath,
                            width: double.infinity,
                            height: AppConstants.imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha((0.7 * 255).toInt()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.event.venue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.event.name,
                            style: theme.textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.event.price,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.favorite_outline,
                              count: widget.event.likes,
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 16),
                            _buildStatItem(
                              icon: Icons.comment_outlined,
                              count: widget.event.comments,
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 16),
                            _buildStatItem(
                              icon: Icons.visibility_outlined,
                              count: widget.event.views,
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            elevation: 0,
                          ),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  final Event event;

  const PlanCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              event.imagePath,
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
}

enum SeatType {
  available,
  reserved,
  selected,
  unavailable,
}

class TicketScreen extends StatefulWidget {
  final Event event;
  final Function(List<Seat>)? onTicketBooked;

  const TicketScreen({
    super.key, 
    required this.event, 
    this.onTicketBooked,
  });

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late List<List<Seat>> _seats;
  int _selectedSeatCount = 0;
  final int _maxSeats = 6; // Maximum seats a user can book

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    final random = Random();
    _seats = List.generate(10, (row) {
      return List.generate(10, (col) {
        // Randomly make some seats unavailable or reserved
        final seatType = random.nextInt(10) < 2 
          ? SeatType.reserved 
          : random.nextInt(10) < 1 
            ? SeatType.unavailable 
            : SeatType.available;
        
        return Seat(
          row: row, 
          col: col, 
          type: seatType,
        );
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
        // Show a snackbar if trying to select more than max seats
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can select a maximum of $_maxSeats seats'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Color _getSeatColor(Seat seat) {
    switch (seat.type) {
      case SeatType.available:
        return seat.isSelected ? Colors.green : Colors.white;
      case SeatType.reserved:
        return Colors.grey;
      case SeatType.selected:
        return Colors.blue;
      case SeatType.unavailable:
        return Colors.red.shade200;
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: ${widget.event.name}'),
              Text('Selected Seats: ${selectedSeats.length}'),
              Text('Total Price: ₹${widget.event.price} x ${selectedSeats.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Close dialog
                Navigator.of(context).pop();

                // Call onTicketBooked callback
                if (widget.onTicketBooked != null) {
                  widget.onTicketBooked!(selectedSeats);
                }

                // Show booking confirmation
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Booking Confirmed'),
                      content: Text('Your tickets have been booked successfully!'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            // Close confirmation dialog
                            Navigator.of(context).pop();
                            
                            // Navigate back to home screen
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text('Back to Home'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Confirm Booking'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),
      body: Column(
        children: [
          // Event details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Date: ${widget.event.date}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Venue: ${widget.event.venue}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          
          // Seat Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.white, 'Available'),
                _buildLegendItem(Colors.green, 'Selected'),
                _buildLegendItem(Colors.grey, 'Reserved'),
                _buildLegendItem(Colors.red.shade200, 'Unavailable'),
              ],
            ),
          ),

          // Seat Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 100, // 10x10 grid
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
                          color: seat.type == SeatType.available 
                            ? Colors.blue 
                            : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${row + 1}-${col + 1}',
                          style: TextStyle(
                            fontSize: 8,
                            color: seat.type == SeatType.available 
                              ? Colors.black 
                              : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Booking Summary and Confirm Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Seats: $_selectedSeatCount',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ElevatedButton(
                  onPressed: _confirmBooking,
                  child: Text('Confirm Booking'),
                ),
              ],
            ),
          ),
        ],
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
          margin: EdgeInsets.only(right: 8),
        ),
        Text(label),
      ],
    );
  }
}

// Models
class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}

class Event {
  final String id;
  final String name;
  final String date;
  final String venue;
  final String price;
  final String imagePath;
  final String description;
  final int likes;
  final int comments;
  final int views;
  final String category;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.venue,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.likes,
    required this.comments,
    required this.views,
    required this.category,
  });
}

// Sample Data
final List<Category> categories = [
  Category(name: 'All', icon: Icons.all_inclusive),
  Category(name: 'Sports', icon: Icons.sports_cricket),
  Category(name: 'Comedy', icon: Icons.theater_comedy),
  Category(name: 'Workshops', icon: Icons.workspaces),
  Category(name: 'Drama', icon: Icons.theater_comedy),
  Category(name: 'Music', icon: Icons.music_note),
  Category(name: 'Art', icon: Icons.palette),
  Category(name: 'Wellness', icon: Icons.self_improvement),
  Category(name: 'Cultural', icon: Icons.celebration),
  Category(name: 'Tech', icon: Icons.code),
  Category(name: 'Cinema', icon: Icons.movie),
];

final List<Event> events = [
  Event(
    id: '1',
    name: 'IPL 2025: CSK vs MI',
    date: 'April 23, 2025',
    venue: 'MA Chidambaram Stadium, Chennai',
    price: '₹1500',
    imagePath: 'assets/images/csk_mi.jpg',
    description: 'Watch Chennai Super Kings take on Mumbai Indians in an electrifying IPL match.',
    likes: 500,
    comments: 45,
    views: 2000,
    category: 'Sports',
  ),
  Event(
    id: '2',
    name: 'IPL 2025: CSK vs RCB',
    date: 'April 28, 2025',
    venue: 'MA Chidambaram Stadium, Chennai',
    price: '₹1800',
    imagePath: 'assets/images/csk_rcb.jpg',
    description: 'A thrilling rivalry match between CSK and RCB.',
    likes: 450,
    comments: 30,
    views: 1800,
    category: 'Sports',
  ),
  Event(
    id: '3',
    name: 'TNPL 2025 Final',
    date: 'July 30, 2025',
    venue: 'Coimbatore Cricket Stadium',
    price: '₹1000',
    imagePath: 'assets/images/tnpl.jpg',
    description: 'Grand finale of the Tamil Nadu Premier League 2025.',
    likes: 300,
    comments: 20,
    views: 1200,
    category: 'Sports',
  ),
  Event(
    id: '4',
    name: 'Madras Comedy Nights',
    date: 'April 15, 2025',
    venue: 'Taj Coromandel, Chennai',
    price: '₹500',
    imagePath: 'assets/images/comedy_nights.jpg',
    description: 'A Tamil stand-up comedy show with top local comedians.',
    likes: 150,
    comments: 15,
    views: 600,
    category: 'Comedy',
  ),
  Event(
    id: '5',
    name: 'Jokes for Reels',
    date: 'May 10, 2025',
    venue: 'Sathyam Cinemas, Chennai',
    price: '₹600',
    imagePath: 'assets/images/jokes_reels.jpg',
    description: 'Hilarious Tamil stand-up comedy event.',
    likes: 120,
    comments: 10,
    views: 500,
    category: 'Comedy',
  ),
  Event(
    id: '6',
    name: 'Coimbatore Laugh Fest',
    date: 'June 5, 2025',
    venue: 'Brookefields Mall, Coimbatore',
    price: '₹400',
    imagePath: 'assets/images/laugh_fest.jpg',
    description: 'A night of laughter with emerging comedians.',
    likes: 100,
    comments: 8,
    views: 400,
    category: 'Comedy',
  ),
  Event(
    id: '7',
    name: 'Photography Workshop',
    date: 'April 20, 2025',
    venue: 'Alliance Française, Chennai',
    price: '₹1500',
    imagePath: 'assets/images/photography_workshop.jpg',
    description: 'Learn professional photography techniques in Chennai.',
    likes: 80,
    comments: 5,
    views: 300,
    category: 'Workshops',
  ),
  Event(
    id: '8',
    name: 'Cooking Class: Tamil Cuisine',
    date: 'May 15, 2025',
    venue: 'Madurai Cultural Center',
    price: '₹1200',
    imagePath: 'assets/images/cooking_class.jpg',
    description: 'Master traditional Tamil dishes with expert chefs.',
    likes: 70,
    comments: 4,
    views: 250,
    category: 'Workshops',
  ),
  Event(
    id: '9',
    name: 'Digital Marketing Bootcamp',
    date: 'June 10, 2025',
    venue: 'Coimbatore Institute of Technology',
    price: '₹2000',
    imagePath: 'assets/images/digital_marketing.jpg',
    description: 'Boost your career with digital marketing skills.',
    likes: 90,
    comments: 6,
    views: 350,
    category: 'Workshops',
  ),
  Event(
    id: '10',
    name: 'Thirukkural Drama',
    date: 'April 25, 2025',
    venue: 'Auditorium, Trichy',
    price: '₹700',
    imagePath: 'assets/images/thirukkural_drama.jpg',
    description: 'A classical Tamil drama based on Thirukkural.',
    likes: 110,
    comments: 7,
    views: 400,
    category: 'Drama',
  ),
  Event(
    id: '11',
    name: 'Silappathikaram Play',
    date: 'May 20, 2025',
    venue: 'Kalaivanar Arangam, Chennai',
    price: '₹900',
    imagePath: 'assets/images/silappathikaram.jpg',
    description: 'Epic Tamil drama performance.',
    likes: 130,
    comments: 9,
    views: 450,
    category: 'Drama',
  ),
  Event(
    id: '12',
    name: 'Modern Tamil Folk Drama',
    date: 'June 15, 2025',
    venue: 'Madurai Cultural Hall',
    price: '₹600',
    imagePath: 'assets/images/folk_drama.jpg',
    description: 'A contemporary take on Tamil folk tales.',
    likes: 100,
    comments: 6,
    views: 350,
    category: 'Drama',
  ),
  Event(
    id: '13',
    name: 'Tamil Retro Nite ft. MJ Shriram',
    date: 'April 30, 2025',
    venue: 'The Leela Palace, Chennai',
    price: '₹1000',
    imagePath: 'assets/images/retro_nite.jpg',
    description: 'A nostalgic music night with Tamil classics.',
    likes: 140,
    comments: 10,
    views: 500,
    category: 'Music',
  ),
  Event(
    id: '14',
    name: 'Art Exhibition: Kolam Art',
    date: 'May 5, 2025',
    venue: 'Pondicherry Museum',
    price: '₹500',
    imagePath: 'assets/images/kolam_art.jpg',
    description: 'Explore traditional Tamil Kolam art.',
    likes: 80,
    comments: 5,
    views: 300,
    category: 'Art',
  ),
  Event(
    id: '15',
    name: 'Yoga Retreat in Ooty',
    date: 'June 1, 2025',
    venue: 'Ooty Hill Retreat Center',
    price: '₹1800',
    imagePath: 'assets/images/yoga_retreat.jpg',
    description: 'A weekend yoga retreat in the hills of Ooty.',
    likes: 90,
    comments: 6,
    views: 350,
    category: 'Wellness',
  ),
  Event(
    id: '16',
    name: 'Pongal Festival Dance',
    date: 'January 14, 2026',
    venue: 'Marina Beach, Chennai',
    price: '₹300',
    imagePath: 'assets/images/pongal_dance.jpg',
    description: 'Traditional dance celebration for Pongal 2026.',
    likes: 200,
    comments: 15,
    views: 800,
    category: 'Cultural',
  ),
  Event(
    id: '17',
    name: 'Tech Conference 2025',
    date: 'May 25, 2025',
    venue: 'Coimbatore Convention Center',
    price: '₹2500',
    imagePath: 'assets/images/tech_conf.jpg',
    description: 'Latest trends in technology by industry experts.',
    likes: 150,
    comments: 12,
    views: 600,
    category: 'Tech',
  ),
  Event(
    id: '18',
    name: 'Tamil Film Screening',
    date: 'April 18, 2025',
    venue: 'Sathyam Cinemas, Chennai',
    price: '₹400',
    imagePath: 'assets/images/tamil_film.jpg',
    description: 'Screening of the latest Tamil blockbuster.',
    likes: 130,
    comments: 10,
    views: 500,
    category: 'Cinema',
  ),
  Event(
    id: '19',
    name: 'Marathon 2025',
    date: 'June 20, 2025',
    venue: 'Chennai Beach Road',
    price: '₹500',
    imagePath: 'assets/images/marathon.jpg',
    description: 'Annual Chennai Marathon for fitness enthusiasts.',
    likes: 120,
    comments: 8,
    views: 400,
    category: 'Sports',
  ),
  Event(
    id: '20',
    name: 'Craft Workshop: Terracotta',
    date: 'May 12, 2025',
    venue: 'Thanjavur Art Gallery',
    price: '₹1000',
    imagePath: 'assets/images/terracotta.jpg',
    description: 'Learn traditional Tamil terracotta crafting.',
    likes: 70,
    comments: 4,
    views: 250,
    category: 'Art',
  ),
];