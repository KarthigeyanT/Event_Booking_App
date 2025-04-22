import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../data/events.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import '../constants/app_constants.dart';
import '../screens/ticket_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final _searchController = TextEditingController();
  late ScrollController _tabScrollController; // New ScrollController for TabBarView
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showSearchBar = false;
  bool _isLoading = true;
  final List<Event> _bookings = [];

  void _navigateToTicketSelection(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketSelectionScreen(event: event),
      ),
    );
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
      final matchesCategory = _selectedCategory == 'All' || event.category.name == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabScrollController = ScrollController();

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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.padding,
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: kToolbarHeight / 2),
                          AnimatedOpacity(
                            opacity: _showSearchBar ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Discover Events',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find the best events in your city',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
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
                                    hintStyle: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: colorScheme.onSurface),
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
                            controller: _tabScrollController,
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
                                  onTap: () => _navigateToTicketSelection(context, event),
                                ),
                              );
                            },
                          );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bookings.isNotEmpty
          ? _buildBookingsBottomBar(theme, colorScheme)
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.map, color: Colors.white),
      ),
    );
  }

  Widget _buildBookingsBottomBar(ThemeData theme, ColorScheme colorScheme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 140,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.padding,
          16,
          AppConstants.padding,
          16,
        ),
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
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bookings.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final event = _bookings[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 100,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            event.imagePath,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.event),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.name,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
