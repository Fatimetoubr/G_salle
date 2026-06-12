# SupSalle Backend — Spring Boot REST API

Backend Java/Spring Boot du projet **Gestion de Réservation des Salles** (SupNum).
Reproduit fidèlement toute la logique métier du projet PHP original.

---

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Language | Java 17 |
| Framework | Spring Boot 3.2 |
| Sécurité | Spring Security + JWT (jjwt 0.11.5) |
| Persistance | Spring Data JPA + Hibernate |
| Base de données | MySQL (supsalle_bd) |
| Email | Spring Mail (Gmail SMTP) |
| Validation | Jakarta Bean Validation |
| Build | Maven |

---

## Lancer le projet

```bash
# 1. Importer la base de données MySQL
mysql -u root -p supsalle_bd < "supsalle_db (7).sql"

# 2. Configurer src/main/resources/application.properties
#    (DB URL, mot de passe, email SMTP)

# 3. Démarrer
mvn spring-boot:run
```

Le serveur démarre sur **http://localhost:8080**

---

## Architecture

```
com.supsalle/
├── entity/          → Entités JPA (User, Salle, Reservation, Notification)
├── repository/      → Interfaces Spring Data JPA
├── dto/             → Objets de transfert (Request / Response)
├── service/         → Logique métier
├── controller/      → Endpoints REST
├── security/        → JWT, Filtre, UserDetailsService, SecurityConfig
└── exception/       → GlobalExceptionHandler + exceptions métier
```

---

## Authentification

Toutes les routes protégées nécessitent le header :
```
Authorization: Bearer <jwt_token>
```

Le JWT est obtenu via `POST /api/auth/login`.

---

## Endpoints

### 🔓 Auth (public)

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/auth/register` | Inscription — crée le compte, envoie un OTP par email |
| POST | `/api/auth/verify-otp` | Vérifie le code OTP pour activer le compte |
| POST | `/api/auth/resend-otp` | Renvoie un nouveau code OTP |
| POST | `/api/auth/login` | Connexion — retourne un JWT + role + userId |
| POST | `/api/auth/forgot-password` | Envoie un OTP de réinitialisation |
| POST | `/api/auth/reset-password` | Réinitialise le mot de passe avec l'OTP |

#### POST /api/auth/register
```json
{
  "fullname": "Ramle Beirouk",
  "email": "ramle@example.com",
  "password": "motdepasse123",
  "confirmPassword": "motdepasse123"
}
```
Réponse `201` :
```json
{ "status": "otp_sent", "email": "ramle@example.com", "message": "..." }
```

#### POST /api/auth/login
```json
{ "email": "ramle@example.com", "password": "motdepasse123" }
```
Réponse `200` :
```json
{
  "token": "eyJhbGci...",
  "role": "user",
  "userId": 9,
  "email": "ramle@example.com",
  "fullname": "Ramle Beirouk"
}
```

#### POST /api/auth/verify-otp
```json
{ "email": "ramle@example.com", "otp": "847291" }
```

#### POST /api/auth/forgot-password
```json
{ "email": "ramle@example.com" }
```

#### POST /api/auth/reset-password
```json
{
  "email": "ramle@example.com",
  "otp": "123456",
  "newPassword": "nouveaumdp123",
  "confirmPassword": "nouveaumdp123"
}
```

---

### 🏫 Salles (authentifié)

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/salles` | Liste toutes les salles |
| GET | `/api/salles/{id}` | Détail d'une salle |
| GET | `/api/salles/{id}/disponibilite?date=YYYY-MM-DD` | Créneaux 30 min (08:00–20:00) avec disponibilité |

#### GET /api/salles
Réponse `200` :
```json
[
  {
    "id": 7,
    "nom": "Hamidoun",
    "type": "salle informatique",
    "capacite": 30,
    "equipements": "Projecteur,test",
    "maintenance": "hors_maintenance"
  }
]
```

#### GET /api/salles/7/disponibilite?date=2025-07-20
```json
{
  "date": "2025-07-20",
  "salleId": 7,
  "salleNom": "Hamidoun",
  "creneaux": [
    { "heureDebut": "08:00", "heureFin": "08:30", "disponible": true },
    { "heureDebut": "08:30", "heureFin": "09:00", "disponible": false },
    ...
  ]
}
```

---

### 📅 Réservations (authentifié — rôle user)

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/reservations` | Créer une réservation (statut "en attente") |
| GET | `/api/reservations/mes-reservations` | Liste des réservations de l'utilisateur connecté |

#### POST /api/reservations
```json
{
  "salleId": 7,
  "date": "2025-07-20",
  "heureDebut": "10:00",
  "heureFin": "11:00"
}
```
Réponse `201` :
```json
{
  "id": 27,
  "salleId": 7,
  "salleNom": "Hamidoun",
  "userId": 9,
  "date": "2025-07-20",
  "heureDebut": "10:00",
  "heureFin": "11:00",
  "statut": "en attente"
}
```

**Règles métier :**
- L'utilisateur doit avoir `is_active = true`
- La salle doit être `hors_maintenance`
- La durée minimale est 30 minutes
- Horaires autorisés : 08:00 → 20:00
- Aucun chevauchement avec une réservation existante

---

### 🔔 Notifications (authentifié)

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/notifications` | Liste des notifications (les marque comme lues) |
| PUT | `/api/notifications/mark-read` | Marquer toutes comme lues |
| GET | `/api/notifications/unread-count` | Nombre de notifications non lues |

---

### 👤 Profil utilisateur (authentifié)

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/user/me` | Informations du compte connecté |

Réponse `200` :
```json
{
  "id": 9,
  "fullname": "Ramle Beirouk",
  "email": "ramle@example.com",
  "isVerified": true,
  "role": "user",
  "isActive": true
}
```

---

### 🔐 Admin — Salles (rôle ADMIN)

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/admin/salles` | Ajouter une salle |
| PUT | `/api/admin/salles/{id}` | Modifier une salle |
| DELETE | `/api/admin/salles/{id}` | Supprimer une salle |

#### POST /api/admin/salles
```json
{
  "nom": "B201",
  "type": "salle de cours",
  "capacite": 35,
  "equipements": "Tableau,Projecteur"
}
```

#### PUT /api/admin/salles/{id}
```json
{
  "nom": "B201",
  "type": "salle de cours",
  "capacite": 35,
  "equipements": "Tableau,Projecteur",
  "maintenance": "en_maintenance"
}
```

---

### 🔐 Admin — Réservations (rôle ADMIN)

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/admin/reservations` | Toutes les réservations |
| PUT | `/api/admin/reservations/{id}/accepter` | Accepter → statut "accepte" + notification |
| PUT | `/api/admin/reservations/{id}/refuser` | Refuser → statut "refuse" + notification |

---

### 🔐 Admin — Utilisateurs (rôle ADMIN)

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/admin/users` | Liste des utilisateurs (role=user) |
| GET | `/api/admin/users/{id}` | Détail d'un utilisateur |
| PUT | `/api/admin/users/{id}` | Modifier un utilisateur |
| PUT | `/api/admin/users/{id}/desactiver` | Désactiver + notification |
| GET | `/api/admin/users/export-csv` | Export CSV compatible Excel |

#### PUT /api/admin/users/{id}
```json
{
  "fullname": "Ramle Beirouk",
  "email": "ramle@example.com",
  "isVerified": true,
  "isActive": true,
  "role": "user"
}
```
> Si `isActive` passe de `false` à `true`, une notification est envoyée automatiquement à l'utilisateur.

#### GET /api/admin/users/export-csv
Télécharge `utilisateurs_export.csv` avec BOM UTF-8 et séparateur `;` (compatible Excel).

---

## Codes d'erreur

| Code | Signification |
|------|---------------|
| 400 | Requête invalide (validation, logique métier) |
| 401 | Non authentifié |
| 403 | Accès interdit (rôle insuffisant) |
| 404 | Ressource non trouvée |
| 409 | Conflit (email déjà utilisé, créneau déjà réservé) |
| 500 | Erreur interne |

Format d'erreur standard :
```json
{
  "timestamp": "2025-07-20T10:00:00",
  "status": 400,
  "message": "Le créneau choisi est déjà réservé."
}
```

---

## Variables d'environnement à configurer

Dans `application.properties` :

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/supsalle_bd
spring.datasource.username=root
spring.datasource.password=VOTRE_MOT_DE_PASSE

spring.mail.username=votre-email@gmail.com
spring.mail.password=votre-app-password-gmail

jwt.secret=CHANGEZ_CE_SECRET_EN_PRODUCTION_MINIMUM_32_CHARS
```

---

## Logique métier préservée

| Fonctionnalité PHP | Équivalent Spring Boot |
|--------------------|------------------------|
| `password_hash()` / `password_verify()` | `BCryptPasswordEncoder` |
| Sessions PHP | JWT stateless |
| PHPMailer SMTP | `JavaMailSender` (Spring Mail) |
| OTP 6 chiffres, 10 min | `AuthService.generateOtp()` |
| Chevauchement créneaux | `ReservationRepository.existsOverlappingReservation()` |
| Notification auto accepter/refuser | `NotificationService.createNotification()` dans `ReservationService` |
| Notification désactivation/activation | `NotificationService.createNotification()` dans `UserService` |
| Export CSV BOM UTF-8 | `ExportService.exportUsersCsv()` |
| Compte désactivé → pas de réservation | Vérifié dans `ReservationService.createReservation()` |
