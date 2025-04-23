import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:incident_report_app/core/services/biometric_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _authController = Get.find<AuthController>();
    final _biometricService = Get.find<BiometricService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (_authController.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _authController.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      } catch (e) {
                        Get.snackbar('Error', e.toString());
                      }
                    }
                  },
                  child: const Text('Login'),
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                if (_biometricService.isBiometricAvailable.value) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      final authenticated = await _authController.loginWithBiometrics();
                      if (!authenticated) {
                        Get.snackbar(
                          'Error',
                          'Biometric authentication failed',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Login with Biometrics'),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.REGISTER);
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 