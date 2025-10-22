import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../widgets/order_card.dart';
import '../../widgets/driver_stats_header.dart';
import 'order_details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);

    if (authService.currentDriver != null) {
      await orderService.loadOrdersForDriver(authService.currentDriver!.id);
      await orderService.loadDriverStats(authService.currentDriver!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthService, OrderService>(
        builder: (context, authService, orderService, _) {
          if (authService.currentDriver == null) {
            return const Center(child: Text('Войдите в систему'));
          }

          return Column(
            children: [
              // Статистика водителя
              DriverStatsHeader(
                driver: authService.currentDriver!,
                stats: orderService.driverStats,
                onProfileTap: () => context.go('/profile'),
              ),

              // Вкладки заказов
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work, size: 18),
                          const SizedBox(width: 4),
                          Text(
                              'В работе (${orderService.inProgressOrders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 18),
                          const SizedBox(width: 4),
                          Text(
                              'Завершенные (${orderService.completedOrders.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.undo, size: 18),
                          const SizedBox(width: 4),
                          Text(
                              'Возвраты (${orderService.returnedOrders.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Список заказов
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(
                        orderService.inProgressOrders, orderService),
                    _buildOrdersList(
                        orderService.completedOrders, orderService),
                    _buildOrdersList(orderService.returnedOrders, orderService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Уже на главной
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/scanner');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Сканнер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, OrderService orderService) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет заказов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => _showOrderDetails(order),
          onTakeOrder: () => orderService.takeOrder(order.id),
        );
      },
    );
  }

  void _showOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
