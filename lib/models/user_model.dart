class User {
  final String id;
  final String? accountId;
  final String? username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final int? birth;
  final String? avatarUrl;
  final Gender gender;
  final int role;
  final String accessToken;

  User({
    required this.id,
    required this.accountId,
    this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.birth,
    this.gender = Gender.other,
    this.avatarUrl,
    required this.role,
    required this.accessToken
  });

  factory User.fromJson(Map json) => User(
    id: json["id"],
    accountId: json["account_id"],
    username: json["username"],
    fullName: json["username"],
    email: json["email"] ?? "",
    phoneNumber: json["phone_number"],
    birth: json["birth"],
    avatarUrl: json["image"],
    gender: _getGenderBasedOnInt(json["gender"]),
    role: json["role"],
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account_id": accountId,
    "username": id,
    "full_name": id,
    "email": email,
    "phone_number": phoneNumber,
    "birth": birth,
    "gender": gender,
    "avatar_url": avatarUrl,
    "role": role,
    "access_token": accessToken
  };
}

enum Gender {
  male, female, other
}

Gender _getGenderBasedOnInt(int? gender) {
  switch (gender) {
      case 1: return Gender.male;  
      case 2: return Gender.female;  
      default: return Gender.other;
    }
}
