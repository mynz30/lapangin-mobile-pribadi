
import 'dart:convert';

List<LapanganEntry> lapanganEntryFromJson(String str) => 
    List<LapanganEntry>.from(json.decode(str).map((x) => LapanganEntry.fromJson(x)));

String lapanganEntryToJson(List<LapanganEntry> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LapanganEntry {
    final int id;
    final String name;
    // Menggunakan tipe enum yang didefinisikan di bawah
    final FieldType type; 
    final String location;
    final int price;
    final double rating;
    final String image;
    final int reviewCount; // reviewCount ditambahkan

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

    factory LapanganEntry.fromJson(Map<String, dynamic> json) => LapanganEntry(
        id: json["id"],
        name: json["name"],
        type: typeValues.map[json["type"]]!, 
        location: json["location"],
        price: json["price"],
        rating: json["rating"]?.toDouble(), 
        image: json["image"],
        reviewCount: json["review_count"],
    );

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
    FUTSAL
}

final typeValues = EnumValues({
    "Basket": FieldType.BASKET,
    "Bulutangkis": FieldType.BULUTANGKIS,
    "Futsal": FieldType.FUTSAL
});

class EnumValues<T> {
    final Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}