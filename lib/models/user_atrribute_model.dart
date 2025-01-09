import 'dart:convert';

UserAttribute userAttributeFromJson(String str) => UserAttribute.fromJson(json.decode(str));

String userAttributeToJson(UserAttribute data) => json.encode(data.toJson());

class UserAttribute {
    int id;
    int userId;
    String attributeValue;

    UserAttribute({
        required this.id,
        required this.userId,
        required this.attributeValue,
    });

    factory UserAttribute.fromJson(Map<String, dynamic> json) => UserAttribute(
        id: json["id"],
        userId: json["user_id"],
        attributeValue: json["attribute_value"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "attribute_value": attributeValue,
    };
}