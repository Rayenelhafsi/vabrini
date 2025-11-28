class Etudiant {
  final int idetudiant;
  final String nom;
  final String prenom;
  final int class_id;
  final String? image_url;

  Etudiant({
    required this.idetudiant,
    required this.nom,
    required this.prenom,
    required this.class_id,
    this.image_url,
  });
}
