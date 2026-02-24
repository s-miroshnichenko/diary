import 'package:flutter/material.dart';

class OnboardingLoginScreen extends StatelessWidget {
  const OnboardingLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.cloud_done_rounded,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 32),

              const Text(
                'Сохраните вашу историю',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Создайте бесплатный аккаунт, чтобы ваши записи автоматически сохранялись в надежном облаке и не потерялись при смене телефона.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              _buildActionButton(
                icon: Icons.apple,
                text: 'Продолжить с Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Логика входа через Apple
                },
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                icon: Icons.g_mobiledata_rounded, 
                text: 'Продолжить с Google',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.grey.shade300,
                onPressed: () {
                  // TODO: Логика входа через Google
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'ИЛИ',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              _buildActionButton(
                icon: Icons.cloud_off_rounded,
                text: 'Продолжить без сохранения',
                backgroundColor: Colors.grey.shade100, 
                textColor: Colors.black87,
                onPressed: () {
                  // TODO: Анонимная авторизация
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Без аккаунта данные хранятся только на этом устройстве.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor, size: 28),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 0, 
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
      ),
    );
  }
}
