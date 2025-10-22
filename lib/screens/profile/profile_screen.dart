import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/driver_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Здесь можно добавить настройки
            },
          ),
        ],
      ),
      body: Consumer2<AuthService, OrderService>(
        builder: (context, authService, orderService, _) {
          final driver = authService.currentDriver;

          if (driver == null) {
            return const Center(
              child: Text('Ошибка загрузки профиля'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Аватар и основная информация
                _buildProfileHeader(context, driver),
                const SizedBox(height: 24),

                // Статистика
                _buildStatsSection(context, orderService.driverStats),
                const SizedBox(height: 24),

                // Настройки
                _buildSettingsSection(context, authService),
                const SizedBox(height: 24),

                // Действия
                _buildActionsSection(context, authService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, driver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              driver.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              driver.phone,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (driver.email != null) ...[
              const SizedBox(height: 4),
              Text(
                driver.email!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(driver.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(driver.status).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getStatusText(driver.status),
                style: TextStyle(
                  color: _getStatusColor(driver.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, DriverStats? stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика заказов',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.work,
                    label: 'В работе',
                    value: '${stats?.currentOrders ?? 0}',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Завершено',
                    value: '${stats?.completedOrders ?? 0}',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.list_alt,
                    label: 'Всего',
                    value: '${stats?.totalOrders ?? 0}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.monetization_on,
                    label: 'Заработано',
                    value:
                        '${stats?.totalEarnings.toStringAsFixed(0) ?? '0'} ₽',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.route,
                    label: 'Пробег',
                    value:
                        '${stats?.totalDistance.toStringAsFixed(1) ?? '0'} км',
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.percent,
                    label: 'Успешность',
                    value:
                        '${stats?.completionRate.toStringAsFixed(0) ?? '0'}%',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthService authService) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Редактировать профиль'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showEditProfileDialog(context, authService);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Уведомления'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Здесь можно добавить логику управления уведомлениями
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Отслеживание GPS'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Здесь можно добавить логику управления GPS
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthService authService) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Помощь'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Здесь можно добавить экран помощи
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context, authService);
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Активен';
      case 'busy':
        return 'Занят';
      case 'inactive':
        return 'Неактивен';
      default:
        return 'Неизвестно';
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthService authService) {
    final nameController =
        TextEditingController(text: authService.currentDriver?.name ?? '');
    final emailController =
        TextEditingController(text: authService.currentDriver?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authService.updateDriverProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Профиль обновлен'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Logistic Driver',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_shipping, size: 48),
      children: [
        const Text(
            'Мобильное приложение для водителей логистической компании.'),
        const SizedBox(height: 16),
        const Text('Версия: 1.0.0'),
        const Text('Разработчик: Logistic Company'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
