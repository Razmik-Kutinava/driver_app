import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/route_service.dart';
import '../../services/location_service.dart';
import '../../widgets/route_card.dart';
import '../../widgets/status_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Откладываем инициализацию до следующего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final routeService = Provider.of<RouteService>(context, listen: false);
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      // final chatService = Provider.of<ChatService>(context, listen: false);

      if (authService.currentDriver != null) {
        // Загружаем маршруты
        await routeService.loadRoutesForDriver(authService.currentDriver!.id);

        // Запускаем отслеживание локации
        await locationService.getCurrentLocation();
        locationService.startLocationTracking();

        // Загружаем сообщения и подписываемся на обновления
        // Временно отключено из-за проблем с REST API
        // await chatService.loadMessages(driverId: authService.currentDriver!.id);
        // chatService.subscribeToMessages(
        //     driverId: authService.currentDriver!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Consumer2<AuthService, RouteService>(
        builder: (context, authService, routeService, _) {
          if (routeService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (routeService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    routeService.error!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeServices(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _initializeServices,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Статус водителя
                  _buildDriverStatus(authService),
                  const SizedBox(height: 24),

                  // Текущий маршрут
                  if (routeService.currentRoute != null) ...[
                    Text(
                      'Текущий маршрут',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    RouteCard(
                      route: routeService.currentRoute!,
                      onTap: () => context.go('/routes'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Список маршрутов
                  Text(
                    'Все маршруты',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  if (routeService.routes.isEmpty)
                    _buildEmptyState()
                  else
                    ...routeService.routes.map((route) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            route: route,
                            onTap: () => context.go('/routes'),
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<RouteService>(
        builder: (context, routeService, _) {
          if (routeService.currentRoute == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => context.go('/routes'),
            icon: const Icon(Icons.directions),
            label: const Text('Маршрут'),
          );
        },
      ),
    );
  }

  Widget _buildDriverStatus(AuthService authService) {
    final driver = authService.currentDriver;
    if (driver == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  StatusIndicator(status: driver.status),
                ],
              ),
            ),
            Consumer<LocationService>(
              builder: (context, locationService, _) {
                return Column(
                  children: [
                    Icon(
                      locationService.isTracking
                          ? Icons.location_on
                          : Icons.location_off,
                      color: locationService.isTracking
                          ? Colors.green
                          : Colors.grey,
                    ),
                    Text(
                      locationService.isTracking ? 'ON' : 'OFF',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.route,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет назначенных маршрутов',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
