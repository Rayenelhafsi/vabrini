class Presence {
  final int idpresence;
  final int etudiant_id;
  final DateTime date;
  final bool is_present;

  Presence({
    required this.idpresence,
    required this.etudiant_id,
    required this.date,
    required this.is_present,
  });
}
