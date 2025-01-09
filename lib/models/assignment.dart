class Assignment {
  int id;
  int doctorId;
  int patientId;

  Assignment({
    required this.id,
    required this.doctorId,
    required this.patientId,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    id: json["id"],
    doctorId: json["doctor_id"],
    patientId: json["patient_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "doctor_id": doctorId,
    "patient_id": patientId,
  };
}