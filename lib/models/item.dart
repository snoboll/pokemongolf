import 'package:flutter/material.dart';

/// A type of inventory item a player can hold.
/// The [id] is the value persisted in the `items.item_type` column.
enum ItemType {
  evoHotDog(
    id: 'evo_hotdog',
    name: 'Evo-HotDog',
    description: 'Use it to evolve one of your Bogeybeasts.',
    icon: Icons.lunch_dining,
    accent: Color(0xFF8A9BB0),
  ),
  takanaj(
    id: 'takanaj',
    name: 'Takanaj',
    description: 'Re-roll the wild Bogeybeast on the current hole.',
    icon: Icons.casino,
    accent: Color(0xFF26A69A),
  );

  const ItemType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  /// Theme color for this item — used across inventory and pickup UI.
  final Color accent;

  static ItemType? fromId(String id) {
    for (final ItemType type in ItemType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
