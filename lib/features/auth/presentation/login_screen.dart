import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/data_providers.dart';
import '../../../routes/app_router.dart';
import 'auth_controller.dart';

/// Login screen — Phase 3 prototype mock authentication.
///
/// Credentials are validated via [AuthController] → [AuthRepository.mockLogin].
/// The UI never touches [MockDataSource] directly.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showDemoHint = false;
  String? _errorMessage;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    authState.when(
      data: (user) {
        if (user == null) return;
        // GoRouter redirect will handle navigation — but we also push here
        // in case the redirect already ran before state updated.
        if (user.isTechnician) {
          context.goNamed(AppRoutes.technicianDashboard);
        } else {
          context.goNamed(AppRoutes.customerDashboard);
        }
      },
      error: (e, _) {
        setState(() {
          _errorMessage = e is AppException ? e.message : 'Login failed. Please try again.';
        });
      },
      loading: () {},
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildBrandHeader(),
                const SizedBox(height: 40),
                _buildLoginCard(isLoading),
                const SizedBox(height: 20),
                _buildDemoCredentialsHint(),
                const SizedBox(height: 32),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Brand Header
  // ---------------------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.medical_services_rounded,
              size: 44,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppConstants.appName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppConstants.appFullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Login Card
  // ---------------------------------------------------------------------------

  Widget _buildLoginCard(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your credentials to continue.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Error banner
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 16),
            ],

            // Email field
            TextFormField(
              key: const Key('login_email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required.';
                if (!v.trim().contains('@')) return 'Enter a valid email address.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              key: const Key('login_password_field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              onFieldSubmitted: (_) => isLoading ? null : _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required.';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Login button
            SizedBox(
              height: 50,
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      key: const Key('login_submit_button'),
                      onPressed: _submit,
                      child: const Text('Sign In'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Demo Credentials Hint (prototype convenience)
  // ---------------------------------------------------------------------------

  Widget _buildDemoCredentialsHint() {
    return GestureDetector(
      onTap: () => setState(() => _showDemoHint = !_showDemoHint),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withAlpha(60)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                const Text(
                  'Demo Credentials',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showDemoHint
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.info,
                ),
              ],
            ),
            if (_showDemoHint) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _credentialRow(
                  label: 'Customer',
                  email: 'admin@rssehat.com',
                  password: 'password123'),
              const SizedBox(height: 8),
              _credentialRow(
                  label: 'Technician',
                  email: 'tech@polaris.com',
                  password: 'password123'),
              const SizedBox(height: 4),
              const Text(
                '⚠ Prototype only — not real credentials.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _credentialRow({
    required String label,
    required String email,
    required String password,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary)),
              Text(password,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildFooter() {
    return Text(
      AppConstants.companyName,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textDisabled,
        fontSize: 11,
        letterSpacing: 0.3,
      ),
    );
  }
}
