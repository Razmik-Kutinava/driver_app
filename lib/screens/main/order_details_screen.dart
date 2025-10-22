import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _pinController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.order.productPrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${widget.order.id.substring(0, 8)}'),
        actions: [
          if (widget.order.isInProgress)
            IconButton(
              onPressed: _showReturnDialog,
              icon: const Icon(Icons.undo),
              tooltip: 'Возврат',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус заказа
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Информация о клиенте
            _buildInfoCard(),

            const SizedBox(height: 16),

            // Информация о товаре
            _buildProductCard(),

            const SizedBox(height: 16),

            // PIN код (если заказ в работе)
            if (widget.order.isInProgress) ...[
              _buildPinCodeCard(),
              const SizedBox(height: 16),
            ],

            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color color;
    String text;
    IconData icon;

    switch (widget.order.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Ожидает взятия в работу';
        icon = Icons.schedule;
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'В работе';
        icon = Icons.work;
        break;
      case 'completed':
        color = Colors.green;
        text = 'Завершен';
        icon = Icons.check_circle;
        break;
      case 'returned':
        color = Colors.red;
        text = 'Возврат';
        icon = Icons.undo;
        break;
      default:
        color = Colors.grey;
        text = 'Неизвестно';
        icon = Icons.help;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус заказа',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о клиенте',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Имя', widget.order.customerName),
            _buildInfoRow(Icons.phone, 'Телефон', widget.order.customerPhone),
            _buildInfoRow(Icons.location_on, 'Адрес', widget.order.address),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о товаре',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.inventory, 'Товар', widget.order.productName),
            _buildInfoRow(Icons.monetization_on, 'Стоимость',
                '${widget.order.productPrice} ₽'),
            if (widget.order.pinCode != null)
              _buildInfoRow(Icons.lock, 'PIN код', widget.order.pinCode!),
          ],
        ),
      ),
    );
  }

  Widget _buildPinCodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Завершение заказа',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'PIN код',
                hintText: 'Введите PIN код от клиента',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Стоимость заказа',
                hintText: 'Укажите итоговую стоимость',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
                suffixText: '₽',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.order.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _takeOrder,
              icon: const Icon(Icons.work),
              label: const Text('Взять в работу'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
        if (widget.order.isInProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _completeOrder,
              icon: const Icon(Icons.check),
              label: const Text('Завершить заказ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
        if (widget.order.isCompleted || widget.order.isReturned) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takeOrder() async {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final success = await orderService.takeOrder(widget.order.id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ взят в работу')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderService.error ?? 'Ошибка')),
        );
      }
    }
  }

  Future<void> _completeOrder() async {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите PIN код')),
      );
      return;
    }

    final orderService = Provider.of<OrderService>(context, listen: false);
    final success = await orderService.completeOrder(
      widget.order.id,
      _pinController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ завершен')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderService.error ?? 'Ошибка')),
        );
      }
    }
  }

  void _showReturnDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Возврат заказа'),
        content: const Text('Вы уверены, что хотите вернуть этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _returnOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Вернуть'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnOrder() async {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final success = await orderService.returnOrder(widget.order.id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ возвращен')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderService.error ?? 'Ошибка')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
