import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  const Category({required this.name, required this.icon});
}

const List<Category> categories = [
  Category(name: 'All', icon: Icons.all_inclusive),
  Category(name: 'Music', icon: Icons.music_note),
  Category(name: 'Sports', icon: Icons.sports_soccer),
  Category(name: 'Food', icon: Icons.restaurant),
  Category(name: 'Art', icon: Icons.palette),
  Category(name: 'Entertainment', icon: Icons.theaters),
  Category(name: 'Tech', icon: Icons.computer),
  Category(name: 'Culture', icon: Icons.people),
  Category(name: 'Health', icon: Icons.health_and_safety),
];
