class Session {
  int id;
  int userId;
  String sessionToken;
  DateTime timeExpiration;

  Session({
    required this.id,
    required this.userId,
    required this.sessionToken,
    required this.timeExpiration,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json["id"],
    userId: json["user_id"],
    sessionToken: json["session_token"],
    timeExpiration: json["time_expiration"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "session_token": sessionToken,
    "time_expiration": timeExpiration,
  };
}
