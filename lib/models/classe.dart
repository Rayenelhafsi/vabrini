class Classe {
  final String classId;
  final String className;

  Classe({required this.classId, required this.className});

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      classId: json['classId'] as String,
      className: json['className'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'classId': classId, 'className': className};
  }

  Classe copyWith({String? classId, String? className}) {
    return Classe(
      classId: classId ?? this.classId,
      className: className ?? this.className,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe &&
        other.classId == classId &&
        other.className == className;
  }

  @override
  int get hashCode {
    return classId.hashCode ^ className.hashCode;
  }
}
