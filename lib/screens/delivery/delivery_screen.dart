import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/route_service.dart';
import '../../models/delivery.dart';

class DeliveryScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Delivery? _delivery;
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadDelivery();
  }

  Future<void> _loadDelivery() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final routeService = Provider.of<RouteService>(context, listen: false);
      final deliveries = await routeService.getDeliveriesForRoute('temp');

      // Находим доставку по ID
      _delivery = deliveries.firstWhere(
        (d) => d.id == widget.deliveryId,
        orElse: () => throw Exception('Доставка не найдена'),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Доставка')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _delivery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Доставка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки доставки',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Доставка не найдена',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Доставка #${_delivery!.sequenceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _openInMaps,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о доставке
            _buildDeliveryInfo(),
            const SizedBox(height: 24),

            // Адрес
            _buildAddressCard(),
            const SizedBox(height: 16),

            // Получатель
            if (_delivery!.recipientName != null) ...[
              _buildRecipientCard(),
              const SizedBox(height: 16),
            ],

            // Заметки
            if (_delivery!.notes != null && _delivery!.notes!.isNotEmpty) ...[
              _buildNotesCard(),
              const SizedBox(height: 16),
            ],

            // Фото доставки
            if (_delivery!.photoUrl != null) ...[
              _buildPhotoCard(),
              const SizedBox(height: 16),
            ],

            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${_delivery!.sequenceNumber}',
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Доставка #${_delivery!.sequenceNumber}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _delivery!.statusText,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Запланировано на ${_formatTime(_delivery!.scheduledTime)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            if (_delivery!.completedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Завершено в ${_formatTime(_delivery!.completedAt!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[600],
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Адрес доставки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _delivery!.address,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.directions),
                label: const Text('Построить маршрут'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Получатель',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _delivery!.recipientName!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (_delivery!.recipientPhone != null) ...[
              const SizedBox(height: 4),
              Text(
                _delivery!.recipientPhone!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Заметки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _delivery!.notes!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Фото доставки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _delivery!.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 48, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_delivery!.isCompleted) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
              const SizedBox(height: 8),
              Text(
                'Доставка завершена',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_delivery!.isPending || _delivery!.isFailed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startDelivery,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Начать доставку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_delivery!.isInProgress) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Сфотографировать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _completeDelivery,
                  icon: const Icon(Icons.check),
                  label: const Text('Завершить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _failDelivery,
              icon: const Icon(Icons.error),
              label: const Text('Не удалось доставить'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
      ),
      child: Text(
        _delivery!.statusText,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_delivery!.status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _openInMaps() {
    // Здесь можно добавить открытие карт
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открытие карт...')),
    );
  }

  Future<void> _startDelivery() async {
    final routeService = Provider.of<RouteService>(context, listen: false);
    final success = await routeService.updateDeliveryStatus(
      _delivery!.id,
      'in_progress',
    );

    if (success) {
      await _loadDelivery();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Доставка начата'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото сделано')),
        );
      }
    }
  }

  Future<void> _completeDelivery() async {
    final routeService = Provider.of<RouteService>(context, listen: false);
    final success = await routeService.updateDeliveryStatus(
      _delivery!.id,
      'completed',
      photoUrl: _selectedImage?.path,
    );

    if (success) {
      await _loadDelivery();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Доставка завершена'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _failDelivery() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Причина неудачи'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Укажите причину...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Здесь можно добавить логику сохранения причины
              final routeService =
                  Provider.of<RouteService>(context, listen: false);
              await routeService.updateDeliveryStatus(
                _delivery!.id,
                'failed',
                failureReason: 'Причина не указана',
              );
              await _loadDelivery();
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}
