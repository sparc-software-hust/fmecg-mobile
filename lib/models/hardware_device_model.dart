class HardwareDevice {
  int id;
  String name;
  String type;

  HardwareDevice({
    required this.id,
    required this.name,
    required this.type,
  });

  factory HardwareDevice.fromJson(Map<String, dynamic> json) => HardwareDevice(
    id: json["id"],
    name: json["name"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
  };
}
