// To parse this JSON data, do
//
//     final community = communityFromJson(jsonString);

import 'dart:convert';

List<Community> communityFromJson(String str) => List<Community>.from(json.decode(str).map((x) => Community.fromJson(x)));

String communityToJson(List<Community> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Community {
    String model;
    int pk;
    Fields fields;

    Community({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Community.fromJson(Map<String, dynamic> json) => Community(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String communityName;
    String description;
    String location;
    int memberCount;
    int maxMember;
    String contactPersonName;
    String sportsType;
    String contactPhone;
    String communityImage;
    DateTime dateAdded;
    bool isActive;
    int createdBy;

    Fields({
        required this.communityName,
        required this.description,
        required this.location,
        required this.memberCount,
        required this.maxMember,
        required this.contactPersonName,
        required this.sportsType,
        required this.contactPhone,
        required this.communityImage,
        required this.dateAdded,
        required this.isActive,
        required this.createdBy,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        communityName: json["community_name"],
        description: json["description"],
        location: json["location"],
        memberCount: json["member_count"],
        maxMember: json["max_member"],
        contactPersonName: json["contact_person_name"],
        sportsType: json["sports_type"],
        contactPhone: json["contact_phone"],
        communityImage: json["community_image"],
        dateAdded: DateTime.parse(json["date_added"]),
        isActive: json["is_active"],
        createdBy: json["created_by"],
    );

    Map<String, dynamic> toJson() => {
        "community_name": communityName,
        "description": description,
        "location": location,
        "member_count": memberCount,
        "max_member": maxMember,
        "contact_person_name": contactPersonName,
        "sports_type": sportsType,
        "contact_phone": contactPhone,
        "community_image": communityImage,
        "date_added": "${dateAdded.year.toString().padLeft(4, '0')}-${dateAdded.month.toString().padLeft(2, '0')}-${dateAdded.day.toString().padLeft(2, '0')}",
        "is_active": isActive,
        "created_by": createdBy,
    };
}
