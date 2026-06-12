import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../services/api.dart';
import '../../services/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

// ═══════════════════════════════════════════════════════════════
// ADMIN SHELL — tabs navigation
// ═══════════════════════════════════════════════════════════════
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _idx = 0;
  static const _screens = [
    AdminSallesScreen(), AdminReservationsScreen(),
    AdminUsersScreen(), AdminCompteScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: AdminDrawer(currentIndex: _idx),
    body: IndexedStack(
      index: _idx,
      children: List.generate(_screens.length, (i) => _AdminTabWrapper(
        index: i, activeIndex: _idx, child: _screens[i],
        onTabChange: (v) => setState(() => _idx = v),
      )),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      backgroundColor: Colors.white,
      indicatorColor: AppColors.accentLight,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.meeting_room_outlined), selectedIcon: Icon(Icons.meeting_room, color: AppColors.primary), label: 'Salles'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary), label: 'Réservations'),
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: AppColors.primary), label: 'Utilisateurs'),
        NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), selectedIcon: Icon(Icons.manage_accounts, color: AppColors.primary), label: 'Compte'),
      ],
    ),
  );
}

class _AdminTabWrapper extends StatelessWidget {
  final int index, activeIndex;
  final Widget child;
  final Function(int) onTabChange;
  const _AdminTabWrapper({required this.index, required this.activeIndex, required this.child, required this.onTabChange});
  @override
  Widget build(BuildContext context) => child;
}

// ═══════════════════════════════════════════════════════════════
// ADMIN SALLES 
// ═══════════════════════════════════════════════════════════════
class AdminSallesScreen extends StatefulWidget {
  const AdminSallesScreen({super.key});
  @override State<AdminSallesScreen> createState() => _AdminSallesState();
}

class _AdminSallesState extends State<AdminSallesScreen> {
  List<SalleModel> _salles = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await Api().getSalles();
      setState(() { _salles = d; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  void _showDialog({SalleModel? s}) {
    final nomCtrl = TextEditingController(text: s?.nom ?? '');
    final capCtrl = TextEditingController(text: s?.capacite.toString() ?? '');
    final eqCtrl  = TextEditingController(text: s?.equipements ?? '');
    String type  = s?.type ?? 'salle de cours';
    String maint = s?.maintenance ?? 'hors_maintenance';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        title: Text(s == null ? 'Ajouter une salle' : 'Modifier ${s.nom}',
          style: const TextStyle(color: AppColors.primary, fontSize: 17)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dField('Nom de la salle *', nomCtrl),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            decoration: _dDeco('Type de salle'),
            items: ['salle de cours','salle informatique','amphithéâtre','laboratoire','autre']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => type = v!)),
          const SizedBox(height: 12),
          _dField('Capacité *', capCtrl, type: TextInputType.number),
          const SizedBox(height: 12),
          _dField('Équipements (séparés par virgule)', eqCtrl),
          if (s != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: maint,
              decoration: _dDeco('État maintenance'),
              items: const [
                DropdownMenuItem(value: 'hors_maintenance', child: Text('Hors maintenance')),
                DropdownMenuItem(value: 'en_maintenance',   child: Text('En maintenance')),
              ],
              onChanged: (v) => ss(() => maint = v!)),
          ],
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final body = {
                'nom': nomCtrl.text.trim(), 'type': type,
                'capacite': int.tryParse(capCtrl.text) ?? 1,
                'equipements': eqCtrl.text.trim(), 'maintenance': maint,
              };
              try {
                if (s == null) await Api().createSalle(body);
                else await Api().updateSalle(s.id, body);
                _load();
                if (mounted) _snack(s == null ? 'Salle ajoutée !' : 'Salle modifiée !', ok: true);
              } on ApiException catch (e) { if (mounted) _snack(e.message); }
            },
            child: Text(s == null ? 'Ajouter' : 'Enregistrer')),
        ],
      ),
    ));
  }

  Future<void> _delete(SalleModel s) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Confirmer', style: TextStyle(color: AppColors.danger)),
      content: Text('Supprimer la salle "${s.nom}" et toutes ses réservations ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer')),
      ],
    ));
    if (ok == true) {
      try { await Api().deleteSalle(s.id); _load(); _snack('Salle supprimée', ok: true); }
      on ApiException catch (e) { _snack(e.message); }
    }
  }

  void _snack(String msg, {bool ok = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: ok ? AppColors.accent : AppColors.danger, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Gestion des salles'),
      actions: [
        IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Ajouter',
          onPressed: () => _showDialog()),
      ],
    ),
    body: _loading ? const AppLoading()
        : _error != null ? AppError(message: _error!, onRetry: _load)
        : RefreshIndicator(
            color: AppColors.primary, onRefresh: _load,
            child: _salles.isEmpty
                ? const Center(child: Text('Aucune salle', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _salles.length,
                    itemBuilder: (_, i) => SalleCard(
                      salle: _salles[i], isAdmin: true,
                      onEdit: () => _showDialog(s: _salles[i]),
                      onDelete: () => _delete(_salles[i])),
                  ),
          ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppColors.accent, foregroundColor: Colors.white,
      icon: const Icon(Icons.add), label: const Text('Ajouter'),
      onPressed: () => _showDialog()),
  );

  Widget _dField(String label, TextEditingController c, {TextInputType? type}) =>
    TextField(controller: c, keyboardType: type, decoration: _dDeco(label));
  InputDecoration _dDeco(String l) => InputDecoration(labelText: l,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2)));
}

// ═══════════════════════════════════════════════════════════════
// ADMIN RÉSERVATIONS 
// ═══════════════════════════════════════════════════════════════
class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});
  @override State<AdminReservationsScreen> createState() => _AdminResaState();
}

class _AdminResaState extends State<AdminReservationsScreen> {
  List<ReservationModel> _all = [], _filtered = [];
  bool _loading = true;
  String _filter = 'en attente';

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await Api().getAllReservations();
      setState(() { _all = d; _applyFilter(_filter); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _applyFilter(String f) => setState(() {
    _filter = f;
    _filtered = f == 'all' ? _all : _all.where((r) => r.statut == f).toList();
  });

  Future<void> _accept(ReservationModel r) async {
    try { await Api().acceptReservation(r.id); _load(); _snack('Réservation acceptée', ok: true); }
    on ApiException catch (e) { _snack(e.message); }
  }

  Future<void> _refuse(ReservationModel r) async {
    try { await Api().refuseReservation(r.id); _load(); _snack('Réservation refusée'); }
    on ApiException catch (e) { _snack(e.message); }
  }

  void _snack(String msg, {bool ok = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: ok ? AppColors.accent : AppColors.danger, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demandes de Réservation'),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(52),
        child: Container(color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('en attente', 'En attente', AppColors.warning),
              _chip('accepte', 'Acceptées', AppColors.accent),
              _chip('refuse', 'Refusées', AppColors.danger),
              _chip('all', 'Toutes', Colors.grey),
            ]))))),
    body: _loading ? const AppLoading()
        : RefreshIndicator(
            color: AppColors.primary, onRefresh: _load,
            child: _filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Aucune réservation $_filter', style: const TextStyle(color: Colors.grey))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _AdminResaCard(
                      r: _filtered[i],
                      onAccept: _filtered[i].isPending ? () => _accept(_filtered[i]) : null,
                      onRefuse: _filtered[i].isPending ? () => _refuse(_filtered[i]) : null)),
          ),
  );

  Widget _chip(String val, String label, Color color) {
    final active = _filter == val;
    return GestureDetector(
      onTap: () => _applyFilter(val),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color)),
        child: Text(label,
          style: TextStyle(color: active ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12))),
    );
  }
}

class _AdminResaCard extends StatelessWidget {
  final ReservationModel r;
  final VoidCallback? onAccept, onRefuse;
  const _AdminResaCard({required this.r, this.onAccept, this.onRefuse});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text('Demande #${r.id}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
          const Spacer(),
          StatusBadge(statut: r.statut),
        ]),
        const Divider(height: 14),
        _row(Icons.meeting_room, r.salleNom ?? 'Salle', bold: true),
        const SizedBox(height: 6),
        _row(Icons.person_outline, '${r.userFullname ?? ''} (${r.userEmail ?? ''})'),
        const SizedBox(height: 6),
        _row(Icons.calendar_today, r.date),
        const SizedBox(height: 6),
        _row(Icons.access_time, '${r.heureDebut} - ${r.heureFin}'),
        if (r.isPending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Accepter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent)),
              onPressed: onAccept)),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Refuser'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              onPressed: onRefuse)),
          ]),
        ],
      ],
    )),
  );

  Widget _row(IconData icon, String text, {bool bold = false}) => Row(children: [
    Icon(icon, size: 15, color: AppColors.primaryLight),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(
      fontSize: 13, color: AppColors.textDark,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// ADMIN USERS 
// ═══════════════════════════════════════════════════════════════
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override State<AdminUsersScreen> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsersScreen> {
  List<UserModel> _users = [], _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override void initState() { super.initState(); _load(); _search.addListener(_onSearch); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await Api().getAllUsers();
      setState(() { _users = d; _filtered = d; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() => _filtered = q.isEmpty ? _users
        : _users.where((u) => u.fullname.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList());
  }

  void _showEdit(UserModel u) {
    final nameCtrl  = TextEditingController(text: u.fullname);
    bool isActive   = u.isActive;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        title: const Text('Modifier utilisateur', style: TextStyle(color: AppColors.primary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          
          SwitchListTile(
            title: const Text('Compte actif'),
            value: isActive, activeColor: AppColors.accent,
            onChanged: (v) => ss(() => isActive = v)),
          
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Api().updateUser(u.id, {
                  'fullname': nameCtrl.text.trim(), 
                  'isActive': isActive, 'role': u.role,
                });
                _load();
                if (mounted) _snack('Utilisateur modifié', ok: true);
              } on ApiException catch (e) { if (mounted) _snack(e.message); }
            },
            child: const Text('Enregistrer')),
        ],
      ),
    ));
  }
Future<void> _delete(UserModel user) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmer'),
      content: Text('Supprimer ${user.fullname} ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await Api().deleteUser(user.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Utilisateur supprimé")),
    );

    await _load(); // ✅ refresh liste
  }
}
  Future<void> _deactivate(UserModel u) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Désactiver le compte ?'),
      content: Text('Désactiver "${u.fullname}" ? L\'utilisateur sera notifié.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, true), child: const Text('Désactiver')),
      ],
    ));
    if (ok == true) {
      try { await Api().deactivateUser(u.id); _load(); _snack('Compte désactivé'); }
      on ApiException catch (e) { _snack(e.message); }
    }
  }

  void _snack(String msg, {bool ok = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: ok ? AppColors.accent : AppColors.warning, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Gestion des utilisateurs'),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(58),
        child: Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          ))),
    ),
    body: _loading ? const AppLoading()
        : RefreshIndicator(
            color: AppColors.primary, onRefresh: _load,
            child: _filtered.isEmpty
                ? const Center(child: Text('Aucun utilisateur trouvé', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _UserCard(
                            user: _filtered[i],
                            onEdit: () => _showEdit(_filtered[i]),
                            onDeactivate: _filtered[i].isActive ? () => _deactivate(_filtered[i]) : null,
                            onActivate: !_filtered[i].isActive ? () async {
                              await Api().updateUser(_filtered[i].id, {
                                'fullname': _filtered[i].fullname,
                                'isActive': true,
                                'role': _filtered[i].role,
                              });
                              _load();
                            } : null,
                            onDelete: () => _delete(_filtered[i]),
                          )),
          ),
  );
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate, onActivate;
  final VoidCallback? onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    this.onDeactivate,
    this.onActivate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 🔹 BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? const Color(0xFFD4EDDA)
                      : const Color(0xFFF8D7DA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: user.isActive
                        ? const Color(0xFF155724)
                        : const Color(0xFF721C24),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 BUTTONS
          Row(
            children: [
              // Modifier
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 15),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: onEdit,
                ),
              ),

              const SizedBox(width: 8),

              // Supprimer
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, size: 15),
                  label: const Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: onDelete, // ✅ IMPORTANT
                ),
              ),

              const SizedBox(width: 8),

              // Désactiver / Activer
              if (onDeactivate != null)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_off, size: 15),
                    label: const Text('Désactiver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: onDeactivate,
                  ),
                )
              else if (onActivate != null)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person, size: 15),
                    label: const Text('Activer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: onActivate,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
// ═══════════════════════════════════════════════════════════════
// ADMIN COMPTE 
// ═══════════════════════════════════════════════════════════════
class AdminCompteScreen extends StatelessWidget {
  const AdminCompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Compte Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          // Avatar admin
          Stack(alignment: Alignment.bottomRight, children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 54)),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.verified, color: AppColors.accent, size: 20)),
          ]),
          const SizedBox(height: 12),
          Text(auth.fullname ?? 'Admin',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(20)),
            child: const Text('Administrateur',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 24),

          // Infos
          Card(child: Padding(padding: const EdgeInsets.all(4), child: Column(children: [
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppColors.primary),
              title: const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
              subtitle: Text(auth.email ?? '',
                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600))),
            const Divider(height: 1),
            const ListTile(
              leading: Icon(Icons.shield_outlined, color: AppColors.primary),
              title: Text('Rôle', style: TextStyle(color: Colors.grey, fontSize: 12)),
              subtitle: Text('Administrateur système',
                style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600))),
          ]))),
          const SizedBox(height: 16),

          // Stats rapides
          Row(children: [
            Expanded(child: _statCard('Salles', Icons.meeting_room, AppColors.accent)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('Réservations', Icons.calendar_month, AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('Utilisateurs', Icons.people, AppColors.warning)),
          ]),
          const SizedBox(height: 16),

          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.lock_reset, color: AppColors.primary),
            label: const Text('Changer le mot de passe', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pushNamed(context, '/forgot-password'))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
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

  Widget _statCard(String label, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), textAlign: TextAlign.center),
      ])));
}
