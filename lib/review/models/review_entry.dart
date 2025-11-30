// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
    int id;
    int field_id;
    String user;
    String content;
    int rating;
    String createdAt;
    bool isOwner;

    ReviewEntry({
        required this.id,
        required this.field_id,
        required this.user,
        required this.content,
        required this.rating,
        required this.createdAt,
        required this.isOwner,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        id: json["id"],
        field_id: json["field_id"],
        user: json["user"],
        content: json["content"],
        rating: json["rating"],
        createdAt: json["created_at"],
        isOwner: json["is_owner"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "field_id": field_id,
        "user": user,
        "content": content,
        "rating": rating,
        "created_at": createdAt,
        "is_owner": isOwner,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
