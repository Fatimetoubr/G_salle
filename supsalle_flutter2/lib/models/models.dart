// ─── User ───────────────────────────────────────────────────
class UserModel {
  final int id;
  final String fullname;
  final String email;
  final bool isVerified;
  final String role;
  final bool isActive;

  UserModel({required this.id, required this.fullname, required this.email,
    required this.isVerified, required this.role, required this.isActive});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], fullname: j['fullname'] ?? '', email: j['email'] ?? '',
    isVerified: j['isVerified'] ?? false, role: j['role'] ?? 'user',
    isActive: j['isActive'] ?? true,
  );
  bool get isAdmin => role == 'admin';
}

// ─── Salle ──────────────────────────────────────────────────
class SalleModel {
  final int id;
  final String nom;
  final String type;
  final int capacite;
  final String? equipements;
  final String maintenance;

  SalleModel({required this.id, required this.nom, required this.type,
    required this.capacite, this.equipements, required this.maintenance});

  factory SalleModel.fromJson(Map<String, dynamic> j) => SalleModel(
    id: j['id'], nom: j['nom'] ?? '', type: j['type'] ?? '',
    capacite: j['capacite'] ?? 0, equipements: j['equipements'],
    maintenance: j['maintenance'] ?? 'hors_maintenance',
  );

  bool get isEnMaintenance => maintenance == 'en_maintenance';
  List<String> get equipementsList =>
      equipements == null || equipements!.isEmpty ? []
      : equipements!.split(',').map((e) => e.trim()).toList();
}

// ─── Reservation ────────────────────────────────────────────
class ReservationModel {
  final int id;
  final int? salleId;
  final String? salleNom;
  final int? userId;
  final String? userFullname;
  final String? userEmail;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String statut;

  ReservationModel({required this.id, this.salleId, this.salleNom,
    this.userId, this.userFullname, this.userEmail,
    required this.date, required this.heureDebut,
    required this.heureFin, required this.statut});

  factory ReservationModel.fromJson(Map<String, dynamic> j) => ReservationModel(
    id: j['id'], salleId: j['salleId'], salleNom: j['salleNom'],
    userId: j['userId'], userFullname: j['userFullname'],
    userEmail: j['userEmail'], date: j['date'] ?? '',
    heureDebut: j['heureDebut'] ?? '', heureFin: j['heureFin'] ?? '',
    statut: j['statut'] ?? 'en attente',
  );

  bool get isAccepted => statut == 'accepte';
  bool get isRefused  => statut == 'refuse';
  bool get isPending  => statut == 'en attente';
}

// ─── Notification ───────────────────────────────────────────
class NotifModel {
  final int id;
  final String message;
  final bool isRead;
  final String createdAt;

  NotifModel({required this.id, required this.message,
    required this.isRead, required this.createdAt});

  factory NotifModel.fromJson(Map<String, dynamic> j) => NotifModel(
    id: j['id'], message: j['message'] ?? '',
    isRead: j['isRead'] ?? false, createdAt: j['createdAt'] ?? '',
  );

  bool get isAccepted    => message.toLowerCase().contains('accept');
  bool get isRefused     => message.toLowerCase().contains('refus');
  bool get isDeactivated => message.toLowerCase().contains('désactiv') ||
                            message.toLowerCase().contains('desactiv');
}

// ─── Creneau ────────────────────────────────────────────────
class CreneauModel {
  final String heureDebut;
  final String heureFin;
  final bool disponible;

  CreneauModel({required this.heureDebut, required this.heureFin, required this.disponible});

  factory CreneauModel.fromJson(Map<String, dynamic> j) => CreneauModel(
    heureDebut: j['heureDebut'] ?? '',
    heureFin: j['heureFin'] ?? '',
    disponible: j['disponible'] ?? true,
  );
}

class DisponibiliteModel {
  final String date;
  final int salleId;
  final String salleNom;
  final List<CreneauModel> creneaux;

  DisponibiliteModel({required this.date, required this.salleId,
    required this.salleNom, required this.creneaux});

  factory DisponibiliteModel.fromJson(Map<String, dynamic> j) => DisponibiliteModel(
    date: j['date'] ?? '', salleId: j['salleId'],
    salleNom: j['salleNom'] ?? '',
    creneaux: (j['creneaux'] as List? ?? [])
        .map((c) => CreneauModel.fromJson(c)).toList(),
  );
}
