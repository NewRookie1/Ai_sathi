import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  String _role = 'artisan'; // selected at registration: artisan or buyer

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? context.t('welcome_back') : context.t('create_account'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? context.t('sign_in_continue')
                      : context.t('join_artisan'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // Role picker: artisan sells, buyer shops.
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'artisan',
                      label: Text('Artisan'),
                      icon: Icon(Icons.handyman_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: 'buyer',
                      label: Text('Buyer'),
                      icon: Icon(Icons.shopping_bag_outlined, size: 18),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) =>
                      setState(() => _role = s.first),
                ),
                const SizedBox(height: 16),
                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.t('full_name'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t('enter_name');
                      }
                      return null;
                    },
                  ),
                if (!_isLogin) const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.t('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.t('enter_email');
                    }
                    if (!value.contains('@')) {
                      return context.t('valid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: context.t('password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.t('enter_password');
                    }
                    if (value.length < 6) {
                      return context.t('password_length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (authService.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authService.error!,
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ElevatedButton(
                  onPressed: authService.isLoading ? null : _submit,
                  child: authService.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_isLogin ? context.t('sign_in') : context.t('create_account')),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() => _isLogin = !_isLogin);
                  },
                  child: Text(
                    _isLogin
                        ? context.t('no_account')
                        : context.t('have_account'),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authService.isLoading ? null : _demoMode,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(context.t('demo_mode')),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        authService.isLoading ? null : _buyerDemoMode,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Try Buyer Demo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _demoMode() async {
    final authService = context.read<AuthService>();

    // Offline demo session: instant, works without the backend.
    final success = await authService.enterDemoMode();
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _buyerDemoMode() async {
    final authService = context.read<AuthService>();
    final success = await authService.enterBuyerDemoMode();
    if (success && mounted) {
      context.go('/buyer-home');
    }
  }

  void _goByRole(String role) {
    if (role == 'buyer') {
      context.go('/buyer-home');
    } else {
      context.go('/home');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    bool success;

    if (_isLogin) {
      success = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: '',
        password: _passwordController.text,
        role: _role,
      );
    }

    if (success && mounted) {
      _goByRole(authService.user?.role ?? _role);
    }
  }
}