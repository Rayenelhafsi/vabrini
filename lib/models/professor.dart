class Professor {
  final String professorId;
  final String name;
  final String firstName;
  final String departmentId;
  final String? imageUrl;

  Professor({
    required this.professorId,
    required this.name,
    required this.firstName,
    required this.departmentId,
    this.imageUrl,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      professorId: json['professorId'] as String,
      name: json['name'] as String,
      firstName: json['firstName'] as String,
      departmentId: json['departmentId'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professorId': professorId,
      'name': name,
      'firstName': firstName,
      'departmentId': departmentId,
      'imageUrl': imageUrl,
    };
  }

  Professor copyWith({
    String? professorId,
    String? name,
    String? firstName,
    String? departmentId,
    String? imageUrl,
  }) {
    return Professor(
      professorId: professorId ?? this.professorId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      departmentId: departmentId ?? this.departmentId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Professor &&
        other.professorId == professorId &&
        other.name == name &&
        other.firstName == firstName &&
        other.departmentId == departmentId &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return professorId.hashCode ^
        name.hashCode ^
        firstName.hashCode ^
        departmentId.hashCode ^
        imageUrl.hashCode;
  }
}
