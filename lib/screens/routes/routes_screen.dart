import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/route_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/delivery_card.dart';
import '../../widgets/route_progress.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршруты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshRoutes(),
          ),
        ],
      ),
      body: Consumer<RouteService>(
        builder: (context, routeService, _) {
          if (routeService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (routeService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки маршрутов',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    routeService.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshRoutes(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (routeService.routes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshRoutes,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routeService.routes.length,
              itemBuilder: (context, index) {
                final route = routeService.routes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRouteCard(route),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteCard(route) {
    return Card(
      child: InkWell(
        onTap: () => _showRouteDetails(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(route.status),
                ],
              ),
              const SizedBox(height: 16),

              // Прогресс маршрута
              RouteProgress(
                completed: route.completedDeliveries,
                total: route.totalDeliveries,
              ),
              const SizedBox(height: 12),

              // Информация о дате и времени
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(route.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${route.completedDeliveries}/${route.totalDeliveries} доставок',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Ожидает';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'В процессе';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Завершен';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Отменен';
        break;
      default:
        color = Colors.grey;
        text = 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Нет маршрутов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ожидайте назначения маршрута от диспетчера',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRouteDetails(route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                route.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),

              // Прогресс
              RouteProgress(
                completed: route.completedDeliveries,
                total: route.totalDeliveries,
              ),
              const SizedBox(height: 24),

              // Список доставок
              Text(
                'Доставки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: route.deliveries.length,
                  itemBuilder: (context, index) {
                    final delivery = route.deliveries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DeliveryCard(
                        delivery: delivery,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/delivery/${delivery.id}');
                        },
                      ),
                    );
                  },
                ),
              ),

              // Кнопки действий
              if (route.status == 'pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startRoute(route.id),
                    child: const Text('Начать маршрут'),
                  ),
                ),
              ] else if (route.status == 'in_progress') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completeRoute(route.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Завершить маршрут'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshRoutes() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final routeService = Provider.of<RouteService>(context, listen: false);

    if (authService.currentDriver != null) {
      await routeService.loadRoutesForDriver(authService.currentDriver!.id);
    }
  }

  Future<void> _startRoute(String routeId) async {
    final routeService = Provider.of<RouteService>(context, listen: false);
    final success = await routeService.startRoute(routeId);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Маршрут начат'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _completeRoute(String routeId) async {
    final routeService = Provider.of<RouteService>(context, listen: false);
    final success = await routeService.completeRoute(routeId);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Маршрут завершен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Сегодня';
    } else if (difference == 1) {
      return 'Вчера';
    } else if (difference < 7) {
      return '$difference дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
