class Departement {
  final String departmentId;
  final String departmentName;

  Departement({required this.departmentId, required this.departmentName});

  factory Departement.fromJson(Map<String, dynamic> json) {
    return Departement(
      departmentId: json['departmentId'] as String,
      departmentName: json['departmentName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'departmentId': departmentId, 'departmentName': departmentName};
  }

  Departement copyWith({String? departmentId, String? departmentName}) {
    return Departement(
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Departement &&
        other.departmentId == departmentId &&
        other.departmentName == departmentName;
  }

  @override
  int get hashCode {
    return departmentId.hashCode ^ departmentName.hashCode;
  }
}
