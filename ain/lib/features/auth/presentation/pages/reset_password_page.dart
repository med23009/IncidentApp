import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/theme/app_theme.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/features/auth/presentation/controllers/auth_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.resetPassword(_emailController.text);
      if (success) {
        Get.back();
        Get.snackbar(
          'Succès',
          'Un email de réinitialisation a été envoyé',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 100,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Réinitialiser le mot de passe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Entrez votre adresse email pour recevoir un lien de réinitialisation',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Constants.requiredField;
                      }
                      if (!GetUtils.isEmail(value)) {
                        return Constants.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (_authController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text('Envoyer le lien'),
                    );
                  }),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Retour à la connexion'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 