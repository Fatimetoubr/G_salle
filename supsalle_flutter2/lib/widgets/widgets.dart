import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/auth_provider.dart';
import '../models/models.dart';

// ─── AppDrawer User ──────────────────────────────────────────
class UserDrawer extends StatelessWidget {
  final int currentIndex;
  final List<String> routes;
  const UserDrawer({super.key, required this.currentIndex, this.routes = const []});

  static const _items = [
    {'icon': Icons.home_outlined,           'label': 'Salles'},
    {'icon': Icons.calendar_today_outlined, 'label': 'Mes Réservations'},
    {'icon': Icons.notifications_outlined,  'label': 'Notifications'},
    {'icon': Icons.settings_outlined,       'label': 'Mon Compte'},
  ];

  static const _routes = ['/home', '/mes-reservations', '/notifications', '/mon-compte'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Drawer(
      child: Container(
        color: AppColors.primary,
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderSide))),
            child: Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.accentLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.fullname ?? 'Utilisateur',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis),
                  Text(auth.email ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 6),
          // Menu items
          ...List.generate(_items.length, (i) {
            final active = currentIndex == i;
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (currentIndex != i) Navigator.pushReplacementNamed(context, _routes[i]);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: active ? AppColors.accentLight : AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(children: [
                  Icon(_items[i]['icon'] as IconData,
                    color: active ? AppColors.primary : AppColors.textLight, size: 20),
                  const SizedBox(width: 12),
                  Text(_items[i]['label'] as String,
                    style: TextStyle(
                      color: active ? AppColors.primary : AppColors.textLight,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    )),
                ]),
              ),
            );
          }),
          const Spacer(),
          _logoutBtn(context),
        ]),
      ),
    );
  }

  Widget _logoutBtn(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: TextButton.icon(
      onPressed: () async {
        await context.read<AuthProvider>().logout();
        if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
    ),
  );
}

// ─── AppDrawer Admin ─────────────────────────────────────────
class AdminDrawer extends StatelessWidget {
  final int currentIndex;
  const AdminDrawer({super.key, required this.currentIndex});

  static const _items = [
    {'icon': Icons.meeting_room_outlined, 'label': 'Gestion des salles'},
    {'icon': Icons.calendar_month,        'label': 'Réservations'},
    {'icon': Icons.people_outline,        'label': 'Utilisateurs'},
    {'icon': Icons.manage_accounts,       'label': 'Mon compte'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Drawer(
      child: Container(
        color: AppColors.primary,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderSide))),
            child: Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.fullname ?? 'Admin',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis),
                  const Text('Administrateur',
                    style: TextStyle(color: AppColors.accentLight, fontSize: 12)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 6),
          ...List.generate(_items.length, (i) {
            final active = currentIndex == i;
            return GestureDetector(
              onTap: () { Navigator.pop(context); },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: active ? AppColors.accentLight : AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(children: [
                  Icon(_items[i]['icon'] as IconData,
                    color: active ? AppColors.primary : AppColors.textLight, size: 20),
                  const SizedBox(width: 12),
                  Text(_items[i]['label'] as String,
                    style: TextStyle(
                      color: active ? AppColors.primary : AppColors.textLight,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    )),
                ]),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String statut;
  const StatusBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late String label;
    late IconData icon;
    switch (statut) {
      case 'accepte':
        bg = const Color(0xFFD4EDDA); fg = const Color(0xFF155724);
        label = 'Acceptée'; icon = Icons.check_circle_outline; break;
      case 'refuse':
        bg = const Color(0xFFF8D7DA); fg = const Color(0xFF721C24);
        label = 'Refusée'; icon = Icons.cancel_outlined; break;
      default:
        bg = const Color(0xFFFFF3CD); fg = const Color(0xFF856404);
        label = 'En attente'; icon = Icons.hourglass_empty;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ─── Salle Card ───────────────────────────────────────────────
class SalleCard extends StatelessWidget {
  final SalleModel salle;
  final VoidCallback? onReserver;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;
  const SalleCard({super.key, required this.salle, this.onReserver,
    this.onEdit, this.onDelete, this.isAdmin = false});

  IconData get _icon {
    switch (salle.type.toLowerCase()) {
      case 'salle informatique': return Icons.computer;
      case 'amphithéâtre': return Icons.school;
      case 'salle de cours': return Icons.class_;
      default: return Icons.meeting_room;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header vert - fidèle au PHP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.primary,
            child: Row(children: [
              Icon(_icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(salle.nom,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
              if (salle.isEnMaintenance)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Maintenance', style: TextStyle(color: Colors.white, fontSize: 10))),
              if (isAdmin) ...[
                IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                const SizedBox(width: 6),
                IconButton(icon: const Icon(Icons.delete, color: Colors.white70, size: 18),
                  onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ]),
          ),
          // Corps carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _row(Icons.category, 'Type', salle.type),
              const SizedBox(height: 8),
              _row(Icons.people, 'Capacité', '${salle.capacite} places'),
              if (salle.equipements != null && salle.equipements!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _row(Icons.build, 'Équipements', salle.equipements!),
              ],
              const SizedBox(height: 8),
              _row(Icons.engineering, 'État',
                salle.isEnMaintenance ? 'En maintenance' : 'Hors maintenance'),
              if (!isAdmin) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: salle.isEnMaintenance ? null : onReserver,
                    icon: const Icon(Icons.event_available),
                    label: Text(salle.isEnMaintenance ? 'Indisponible' : 'Réserver cette salle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.primary, size: 17),
      const SizedBox(width: 8),
      Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
    ],
  );
}

// ─── Loading / Error ──────────────────────────────────────────
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});
  @override
  Widget build(BuildContext context) =>
    const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppError({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDark)),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Réessayer', style: TextStyle(color: Colors.white))),
        ],
      ],
    )),
  );
}

// ─── Input Field helper ───────────────────────────────────────
class AppInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController ctrl;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final int? maxLength;

  const AppInput({super.key, required this.label, required this.icon,
    required this.ctrl, this.obscure = false, this.suffix, this.type,
    this.validator, this.maxLength});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure,
    keyboardType: type, maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryLight),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      counterText: maxLength != null ? null : '',
    ),
    validator: validator,
  );
}
