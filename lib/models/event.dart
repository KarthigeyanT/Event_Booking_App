import 'category.dart';

class Event {
  final String id;
  final String name;
  final String venue;
  final String date;
  final String time;
  final String price;
  final String imagePath; // For asset images
  final String? imageUrl; // Optional network image URL
  final String description;
  final int likes;
  final int comments;
  final int views;
  final Category category;
  final List<TicketOption> ticketOptions;
  final double rating;
  final String location;

  const Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.date,
    this.time = '19:00',
    required this.price,
    required this.imagePath,
    this.imageUrl,
    required this.description,
    required this.likes,
    required this.comments,
    required this.views,
    required this.category,
    this.ticketOptions = const [
      TicketOption(
        type: TicketType.general,
        price: 0,
        description: 'General Admission'
      )
    ],
    this.rating = 4.5,
    this.location = '',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      venue: json['venue'],
      date: json['date'],
      time: json['time'] ?? '19:00',
      price: json['price'],
      imagePath: json['imagePath'] ?? 'assets/images/event_placeholder.png',
      imageUrl: json.containsKey('imageUrl') ? json['imageUrl'] : null,
      description: json['description'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      views: json['views'] ?? 0,
      category: categories.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => categories.first,
      ),
      ticketOptions: (json['ticketOptions'] as List?)?.map((e) => TicketOption.fromJson(e)).toList() ?? 
          [TicketOption(type: TicketType.general, price: double.parse(json['price']), description: 'General Admission')],
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'venue': venue,
      'date': date,
      'time': time,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'likes': likes,
      'comments': comments,
      'views': views,
      'category': category.name,
      'ticketOptions': ticketOptions.map((e) => e.toJson()).toList(),
      'rating': rating,
      'location': location,
    };
  }
}

class TicketOption {
  final TicketType type;
  final double price;
  final String description;
  final int? availableQuantity;

  const TicketOption({
    required this.type,
    required this.price,
    required this.description,
    this.availableQuantity,
  });

  factory TicketOption.fromJson(Map<String, dynamic> json) {
    return TicketOption(
      type: TicketType.values.firstWhere((e) => e.name == json['type']),
      price: json['price'],
      description: json['description'],
      availableQuantity: json['availableQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'price': price,
      'description': description,
      if (availableQuantity != null) 'availableQuantity': availableQuantity,
    };
  }
}

enum TicketType {
  general('General Admission'),
  vip('VIP'),
  student('Student'),
  earlyBird('Early Bird'),
  premium('Premium');

  final String name;
  const TicketType(this.name);
}
