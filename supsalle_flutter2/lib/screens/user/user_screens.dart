import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/api.dart';
import '../../services/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

// ═══════════════════════════════════════════════════════════════
// USER HOME — Les Salles du SupNum 
// ═══════════════════════════════════════════════════════════════
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});
  @override State<UserHomeScreen> createState() => _HomeState();
}

class _HomeState extends State<UserHomeScreen> {
  List<SalleModel> _salles = [], _filtered = [];
  bool _loading = true;
  String? _error;
  String _activeFilter = 'all';
  int _unread = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final salles = await Api().getSalles();
      final unread = await Api().getUnreadCount();
      setState(() { _salles = salles; _filtered = salles; _unread = unread; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  void _filter(String type) {
    setState(() {
      _activeFilter = type;
      _filtered = type == 'all' ? _salles
          : _salles.where((s) => s.type.toLowerCase().contains(type)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentIndex: 0),
      appBar: AppBar(
        title: const Text('Les Salles du SupNum'),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.pushNamed(context, '/notifications')),
            if (_unread > 0) Positioned(right: 8, top: 8,
              child: Container(width: 16, height: 16,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('$_unread',
                  style: const TextStyle(color: Colors.white, fontSize: 10))))),
          ]),
        ],
      ),
      body: _loading ? const AppLoading()
          : _error != null ? AppError(message: _error!, onRetry: _load)
          : RefreshIndicator(
              color: AppColors.primary, onRefresh: _load,
              child: Column(children: [
                // Filtres (identiques au PHP)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _chip('all', 'Toutes'),
                      _chip('cours', 'Salles de cours'),
                      _chip('informatique', 'Informatique'),
                      _chip('laboratoire', 'Laboratoires'),
                      _chip('amphithéâtre', 'Amphithéâtres'),
                    ]),
                  ),
                ),
                // Liste salles
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Aucune salle disponible', style: TextStyle(color: Colors.grey))]))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => SalleCard(
                            salle: _filtered[i],
                            onReserver: () => Navigator.pushNamed(context, '/reserver', arguments: _filtered[i]),
                          ),
                        ),
                ),
              ]),
            ),
    );
  }

  Widget _chip(String type, String label) {
    final active = _activeFilter == type;
    return GestureDetector(
      onTap: () => _filter(type),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : Colors.grey.shade300)),
        child: Text(label, style: TextStyle(
          color: active ? Colors.white : AppColors.textDark,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          fontSize: 13)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOUVELLE RÉSERVATION (User_nouvelle_reservastion.php)
// ═══════════════════════════════════════════════════════════════
class NouvelleReservationScreen extends StatefulWidget {
  const NouvelleReservationScreen({super.key});
  @override State<NouvelleReservationScreen> createState() => _ResaState();
}

class _ResaState extends State<NouvelleReservationScreen> {
  SalleModel? _salle;
  DateTime _date = DateTime.now();
  DisponibiliteModel? _dispo;
  String? _debutSelected, _finSelected;
  bool _loadingDispo = false, _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _salle = ModalRoute.of(context)?.settings.arguments as SalleModel?;
    if (_salle != null) _loadDispo();
  }

  Future<void> _loadDispo() async {
    setState(() { _loadingDispo = true; _debutSelected = null; _finSelected = null; });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      final d = await Api().getDisponibilite(_salle!.id, dateStr);
      setState(() { _dispo = d; _loadingDispo = false; });
    } catch (_) { setState(() => _loadingDispo = false); }
  }

  Future<void> _reserver() async {
    if (_debutSelected == null || _finSelected == null) {
      _snack('Sélectionnez un créneau de début et de fin', error: true); return;
    }
    setState(() => _saving = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      await Api().createReservation(_salle!.id, dateStr, '$_debutSelected:00', '$_finSelected:00');
      if (!mounted) return;
      _snack('Réservation envoyée ! En attente de validation.', error: false);
      Navigator.pop(context);
    } on ApiException catch (e) { _snack(e.message, error: true); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  void _snack(String msg, {required bool error}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.accent,
      behavior: SnackBarBehavior.floating));

  void _selectCreneau(CreneauModel c) {
    if (!c.disponible) return;
    setState(() {
      if (_debutSelected == null) {
        _debutSelected = c.heureDebut;
        _finSelected   = c.heureFin;
      } else if (_debutSelected == c.heureDebut) {
        _debutSelected = null; _finSelected = null;
      } else {
        // Étendre la sélection vers la fin
        _finSelected = c.heureFin;
      }
    });
  }

  bool _isInRange(CreneauModel c) {
    if (_debutSelected == null || _finSelected == null) return false;
    return c.heureDebut.compareTo(_debutSelected!) >= 0 &&
           c.heureFin.compareTo(_finSelected!) <= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_salle?.nom ?? 'Réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info salle
          if (_salle != null) Card(
            child: Padding(padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.meeting_room, color: AppColors.primary, size: 26)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_salle!.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  Text('${_salle!.type} • ${_salle!.capacite} places',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
              ])),
          ),
          const SizedBox(height: 16),

          // Sélecteur date
          const Text('Date de réservation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                  child: child!),
              );
              if (picked != null) { setState(() => _date = picked); _loadDispo(); }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date),
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Créneaux
          Row(children: [
            const Text('Créneaux disponibles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
            const Spacer(),
            // Légende
            _legendItem(AppColors.accentLight, 'Libre'),
            const SizedBox(width: 8),
            _legendItem(const Color(0xFFF8D7DA), 'Occupé'),
            const SizedBox(width: 8),
            _legendItem(AppColors.primary, 'Sélectionné'),
          ]),
          const SizedBox(height: 10),
          if (_loadingDispo)
            const Center(child: Padding(padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_dispo == null)
            const Text('Impossible de charger les créneaux', style: TextStyle(color: Colors.grey))
          else
            Wrap(spacing: 8, runSpacing: 8,
              children: _dispo!.creneaux.map((c) {
                final inRange = _isInRange(c);
                Color bg, border;
                Color textColor;
                if (!c.disponible) {
                  bg = const Color(0xFFF8D7DA); border = const Color(0xFF721C24); textColor = const Color(0xFF721C24);
                } else if (inRange) {
                  bg = AppColors.primary; border = AppColors.primary; textColor = Colors.white;
                } else {
                  bg = AppColors.accentLight; border = AppColors.accent; textColor = AppColors.primary;
                }
                return GestureDetector(
                  onTap: () => _selectCreneau(c),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border)),
                    child: Column(children: [
                      Text(c.heureDebut,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      Text('→ ${c.heureFin}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.8))),
                    ]),
                  ),
                );
              }).toList()),
          const SizedBox(height: 20),

          // Récapitulatif sélection
          if (_debutSelected != null && _finSelected != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.accentLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent)),
              child: Row(children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 10),
                Text('Créneau sélectionné : $_debutSelected → $_finSelected',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ]),
            ),

          // Bouton confirmer
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _reserver,
              icon: const Icon(Icons.event_available),
              label: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirmer la réservation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// MES RÉSERVATIONS (User_liste_reservations.php)
// ═══════════════════════════════════════════════════════════════
class MesReservationsScreen extends StatefulWidget {
  const MesReservationsScreen({super.key});
  @override State<MesReservationsScreen> createState() => _MesResaState();
}

class _MesResaState extends State<MesReservationsScreen> {
  List<ReservationModel> _list = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await Api().getMyReservations();
      setState(() { _list = d; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentIndex: 1),
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: _loading ? const AppLoading()
          : _error != null ? AppError(message: _error!, onRetry: _load)
          : RefreshIndicator(
              color: AppColors.primary, onRefresh: _load,
              child: _list.isEmpty
                  ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aucune réservation trouvée', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Réservez une salle depuis l\'accueil',
                        style: TextStyle(color: Colors.grey, fontSize: 12))]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _list.length,
                      itemBuilder: (_, i) => _ResaCard(r: _list[i]),
                    ),
            ),
    );
  }
}

class _ResaCard extends StatelessWidget {
  final ReservationModel r;
  const _ResaCard({required this.r});

  Color get _borderColor => r.isAccepted ? AppColors.accent : r.isRefused ? AppColors.danger : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: _borderColor, width: 5))),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.meeting_room, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(r.salleNom ?? 'Salle',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary))),
            StatusBadge(statut: r.statut),
          ]),
          const Divider(height: 16),
          _row(Icons.calendar_today, 'Date', r.date),
          const SizedBox(height: 6),
          _row(Icons.access_time, 'Heure', '${r.heureDebut} → ${r.heureFin}'),
          const SizedBox(height: 6),
          _row(Icons.info_outline, 'Réservation', '#${r.id}'),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String val) => Row(children: [
    Icon(icon, size: 15, color: AppColors.primaryLight),
    const SizedBox(width: 8),
    Text('$label : ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
    Text(val, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 13)),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// NOTIFICATIONS (User_Notification.php)
// ═══════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotifState();
}

class _NotifState extends State<NotificationsScreen> {
  List<NotifModel> _list = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await Api().getNotifications();
      setState(() { _list = d; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _bgColor(NotifModel n) {
    if (n.isRefused || n.isDeactivated) return const Color(0xFFFDF0F0);
    if (n.isAccepted) return const Color(0xFFF0F9F0);
    return Colors.white;
  }

  Color _accentColor(NotifModel n) {
    if (n.isRefused || n.isDeactivated) return AppColors.danger;
    if (n.isAccepted) return AppColors.accent;
    return AppColors.warning;
  }

  IconData _icon(NotifModel n) {
    if (n.isRefused) return Icons.cancel;
    if (n.isDeactivated) return Icons.person_off;
    if (n.isAccepted) return Icons.check_circle;
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentIndex: 2),
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading ? const AppLoading()
          : RefreshIndicator(
              color: AppColors.primary, onRefresh: _load,
              child: _list.isEmpty
                  ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aucune notification', style: TextStyle(color: Colors.grey))]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _list.length,
                      itemBuilder: (_, i) {
                        final n = _list[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _bgColor(n),
                            border: Border(left: BorderSide(color: _accentColor(n), width: 4)),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]),
                          padding: const EdgeInsets.all(14),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(_icon(n), color: _accentColor(n), size: 22),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(n.message,
                                style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                n.createdAt.length >= 10 ? n.createdAt.substring(0, 10) : n.createdAt,
                                style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ])),
                          ]),
                        );
                      }),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MON COMPTE (User_compte.php)
// ═══════════════════════════════════════════════════════════════
class MonCompteScreen extends StatefulWidget {
  const MonCompteScreen({super.key});
  @override State<MonCompteScreen> createState() => _CompteState();
}

class _CompteState extends State<MonCompteScreen> {
  UserModel? _user;
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final u = await Api().getMyProfile();
      setState(() { _user = u; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      drawer: const UserDrawer(currentIndex: 3),
      appBar: AppBar(title: const Text('Mon Compte')),
      body: _loading ? const AppLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 52)),
                const SizedBox(height: 12),
                Text(auth.fullname ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 6),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: (_user?.isActive ?? true) ? const Color(0xFFD4EDDA) : const Color(0xFFF8D7DA),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    (_user?.isActive ?? true) ? '✓ Compte actif' : '✗ Compte inactif',
                    style: TextStyle(
                      color: (_user?.isActive ?? true) ? const Color(0xFF155724) : const Color(0xFF721C24),
                      fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(height: 24),

                // Infos
                Card(child: Padding(padding: const EdgeInsets.all(4), child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.primary),
                    title: const Text('Nom complet', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(auth.fullname ?? '',
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600))),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                    title: const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(auth.email ?? '',
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600))),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                    title: const Text('Statut', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(
                      (_user?.isVerified ?? false) ? 'Compte vérifié' : 'Non vérifié',
                      style: TextStyle(
                        color: (_user?.isVerified ?? false) ? AppColors.accent : AppColors.warning,
                        fontWeight: FontWeight.w600))),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined, color: AppColors.accent),
                    title: const Text('Contactez-nous'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () => _showContact(context)),
                ]))),
                const SizedBox(height: 16),

                // Bouton changer mdp
                SizedBox(width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_reset, color: AppColors.primary),
                    label: const Text('Changer le mot de passe',
                      style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'))),
                const SizedBox(height: 12),

                // Déconnexion
                SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    })),
              ]),
            ),
    );
  }

  void _showContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Contactez-nous',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
              child: const Icon(Icons.email, color: AppColors.primary)),
            title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('24128@supnum.mr')),
          ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFDCF8C6), shape: BoxShape.circle),
              child: const Icon(Icons.chat, color: Colors.green)),
            title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('+222 41 77 13 94')),
          ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
              child: const Icon(Icons.language, color: AppColors.primary)),
            title: const Text('Site web', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('www.supnum.mr')),
        ]),
      ),
    );
  }
}
