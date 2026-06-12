import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../services/api.dart';
import '../../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────
// SPLASH
// ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1800), _go);
  }

  void _go() async {
    final auth = context.read<AuthProvider>();
    await auth.load();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, auth.isLoggedIn ? (auth.isAdmin ? '/admin' : '/home') : '/login');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppColors.loginGradient),
      child: FadeTransition(
        opacity: _fade,
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.meeting_room, color: Colors.white, size: 56)),
          const SizedBox(height: 20),
          const Text('SupSalle',
            style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Institut Supérieur du Numérique',
            style: TextStyle(color: AppColors.accentLight, fontSize: 13)),
          const SizedBox(height: 50),
          const SizedBox(width: 28, height: 28,
            child: CircularProgressIndicator(color: AppColors.accentLight, strokeWidth: 2)),
        ])),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _form  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obs = true, _loading = false;

  Future<void> _login() async {
  if (!_form.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    final role = await context.read<AuthProvider>().login(
      _email.text.trim(),
      _pass.text,
    );

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      role == 'admin' ? '/admin' : '/home',
    );

  } on ApiException catch (e) {
    // ✅ affiche vraie erreur backend
    print("API ERROR: ${e.message}");
    _snack(e.message, error: true);

  } catch (e) {
    // ✅ affiche erreur réelle
    print("UNKNOWN ERROR: $e");
    _snack('Erreur: $e', error: true);

  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  void _snack(String msg, {bool error = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.accent,
      behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppColors.loginGradient),
      child: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Logo
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.meeting_room, color: Colors.white, size: 44)),
          const SizedBox(height: 14),
          const Text('SupSalle',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Text('Gestion de Réservation',
            style: TextStyle(color: AppColors.accentLight, fontSize: 13)),
          const SizedBox(height: 32),
          // Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
            child: Form(key: _form, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Connexion',
                  style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 22),
                AppInput(label: 'Email', icon: Icons.email_outlined, ctrl: _email,
                  type: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null),
                const SizedBox(height: 14),
                AppInput(
                  label: 'Mot de passe', icon: Icons.lock_outline, ctrl: _pass, obscure: _obs,
                  suffix: IconButton(
                    icon: Icon(_obs ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obs = !_obs)),
                  validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null),
                const SizedBox(height: 22),
                SizedBox(width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Se connecter',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
              ],
            )),
          ),
          const SizedBox(height: 18),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
    // ❌ désactivé
        TextButton(
            onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fonction désactivée")),
        );
      },
      child: const Text(
        'Mot de passe oublié',
        style: TextStyle(color: AppColors.accentLight),
        ),
          ),

        const Text('•', style: TextStyle(color: AppColors.accentLight)),

    // ✅ vers register
    TextButton(
      onPressed: () => Navigator.pushNamed(context, '/register'),
      child: const Text(
        'Créer un compte',
        style: TextStyle(color: AppColors.accentLight),
      ),
        ),
      ],
        )
        ]),
      ))),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// REGISTER
// ─────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegState();
}

class _RegState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obs1 = true, _obs2 = true, _loading = false;

  Future<void> _register() async {
  if (!_form.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    await Api().register(
      _name.text.trim(),
      _email.text.trim(),
      _pass.text,
      _confirm.text,
    );

    if (!mounted) return;

    // ✅ message succès
    _snack("Compte créé avec succès", ok: true);

    // ✅ aller directement vers login
    Navigator.pushReplacementNamed(context, '/login');

  } on ApiException catch (e) {
    print("API ERROR: ${e.message}");
    _snack(e.message);

  } catch (e) {
    print("UNKNOWN ERROR: $e");
    _snack("Erreur: $e");

  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  void _snack(String msg, {bool ok = false}) {
  print("SNACK: $msg");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: ok ? AppColors.accent : AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppColors.loginGradient),
      child: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.person_add, color: Colors.white, size: 54),
          const SizedBox(height: 10),
          const Text('Créer un compte',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
            child: Form(key: _form, child: Column(children: [
              AppInput(label: 'Nom complet', icon: Icons.person_outline, ctrl: _name,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null),
              const SizedBox(height: 12),
              AppInput(label: 'Email', icon: Icons.email_outlined, ctrl: _email,
                type: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null),
              const SizedBox(height: 12),
              AppInput(label: 'Mot de passe (min 8 car.)', icon: Icons.lock_outline,
                ctrl: _pass, obscure: _obs1,
                suffix: IconButton(icon: Icon(_obs1 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obs1 = !_obs1)),
                validator: (v) => v == null || v.length < 8 ? 'Min 8 caractères' : null),
              const SizedBox(height: 12),
              AppInput(label: 'Confirmer mot de passe', icon: Icons.lock_outline,
                ctrl: _confirm, obscure: _obs2,
                suffix: IconButton(icon: Icon(_obs2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obs2 = !_obs2)),
                validator: (v) => v != _pass.text ? 'Les mots de passe ne correspondent pas' : null),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("S'inscrire", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
            ])),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('← Retour à la connexion', style: TextStyle(color: AppColors.accentLight))),
        ]),
      ))),
    ),
  );
}
