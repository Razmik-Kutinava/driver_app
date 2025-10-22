import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback? onTakeOrder;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onTakeOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с статусом
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),

              const SizedBox(height: 8),

              // Информация о клиенте
              _buildInfoRow(Icons.person, order.customerName),
              _buildInfoRow(Icons.phone, order.customerPhone),
              _buildInfoRow(Icons.location_on, order.address),
              _buildInfoRow(Icons.monetization_on, '${order.productPrice} ₽'),

              const SizedBox(height: 12),

              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Детали'),
                    ),
                  ),
                  if (order.isPending && onTakeOrder != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTakeOrder,
                        icon: const Icon(Icons.work, size: 16),
                        label: const Text('Взять в работу'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (order.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Ожидает';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'В работе';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Завершен';
        break;
      case 'returned':
        color = Colors.red;
        text = 'Возврат';
        break;
      default:
        color = Colors.grey;
        text = 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
}


