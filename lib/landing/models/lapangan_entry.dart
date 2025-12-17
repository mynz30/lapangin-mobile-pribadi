// lib/landing/models/lapangan_entry.dart
import 'dart:convert';

List<LapanganEntry> lapanganEntryFromJson(String str) => 
    List<LapanganEntry>.from(json.decode(str).map((x) => LapanganEntry.fromJson(x)));

String lapanganEntryToJson(List<LapanganEntry> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LapanganEntry {
  final int id;
  final String name;
  final FieldType type; 
  final String location;
  final int price;
  final double rating;
  final String image;
  final int reviewCount;

  const LapanganEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    required this.reviewCount,
  });

  factory LapanganEntry.fromJson(Map<String, dynamic> json) {
    // Safely parse rating
    double parsedRating = 0.0;
    if (json["rating"] != null) {
      if (json["rating"] is double) {
        parsedRating = json["rating"];
      } else if (json["rating"] is int) {
        parsedRating = (json["rating"] as int).toDouble();
      } else if (json["rating"] is String) {
        parsedRating = double.tryParse(json["rating"]) ?? 0.0;
      }
    }

    return LapanganEntry(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      type: typeValues.map[json["type"]] ?? FieldType.FUTSAL, 
      location: json["location"] ?? "",
      price: json["price"] ?? 0,
      rating: parsedRating,
      image: json["image"] ?? "",
      reviewCount: json["review_count"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": typeValues.reverse[type], 
    "location": location,
    "price": price,
    "rating": rating,
    "image": image,
    "review_count": reviewCount,
  };
}

enum FieldType {
  BASKET,
  BULUTANGKIS,
  FUTSAL,
  VOLI,  // Added Voli
}

final typeValues = EnumValues({
  "Basket": FieldType.BASKET,
  "Bulutangkis": FieldType.BULUTANGKIS,
  "Futsal": FieldType.FUTSAL,
  "Voli": FieldType.VOLI,
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}