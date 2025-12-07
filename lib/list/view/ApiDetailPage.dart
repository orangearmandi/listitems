import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:listitems/config/configuration.dart';
import '../cubit/apitcubit.dart';
import 'package:flutter/material.dart';

class ApiDetailPage extends StatelessWidget {
  final String id;
  const ApiDetailPage({super.key, required this.id});

  void _showDeleteDialog(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Item'),
          content: const Text('Confirmar la eliminacion del item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<ApiCubit>()
                    .deleteItem(itemId)
                    .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item eliminado')),
                      );
                      context.go('/');
                    })
                    .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar el item: $error'),
                        ),
                      );
                    });
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiCubit, ApiState>(
      builder: (context, state) {
        if (state is ApiLoaded) {
          final item = state.items.firstWhere((item) => item.id == id);
          return Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => context.go('/'),
              ),
              title: Text(
                item.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),

              backgroundColor: Colors.blueAccent,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product: ${item.productName}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description: ${item.descripcion}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Created: ${item.created}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: \$${item.precio}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          if (item.imagen.isNotEmpty)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${ConfigurationApiList().apiBaseUrl}/api/files/pbc_2167874626/$id/${item.imagen}',
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        size: 200,
                                      ),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.redAccent,
                                onPressed: () =>
                                    _showDeleteDialog(context, item.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.green,
                                onPressed: () =>
                                    context.go('/api/edit/${item.id}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
