class EcgRecord {
  int id;
  int userId;
  int deviceId;
  String dataDirectory;

  EcgRecord({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.dataDirectory,
  });

  factory EcgRecord.fromJson(Map<String, dynamic> json) => EcgRecord(
    id: json["id"],
    userId: json["user_id"],
    deviceId: json["device_id"],
    dataDirectory: json["data_directory"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "device_id": deviceId,
    "data_directory": dataDirectory,
  };
}
