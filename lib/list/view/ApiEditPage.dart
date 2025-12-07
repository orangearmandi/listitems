import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/apitcubit.dart';
import '../model/item.dart';

// --- ApiEditPage ---

class ApiEditPage extends StatefulWidget {
  final Item itemToEdit;
  const ApiEditPage({super.key, required this.itemToEdit});

  @override
  State<ApiEditPage> createState() => _ApiEditPageState();
}

class _ApiEditPageState extends State<ApiEditPage> {
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController descripcionCtrl = TextEditingController();
  final TextEditingController precioCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    productNameCtrl.text = widget.itemToEdit.productName;
    descripcionCtrl.text = widget.itemToEdit.descripcion;
    precioCtrl.text = widget.itemToEdit.precio.toString();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = kIsWeb ? null : File(pickedFile.path);
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => context.go('/'),
        ),
        title: const Text('Edit Item', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: productNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: const Icon(Icons.shopping_bag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descripcionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: precioCtrl,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Image (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        if (_imageBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<ApiCubit, ApiState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is! ApiLoading ? _updateItem : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: state is ApiLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Item'),
                );
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateItem() {
    final productName = productNameCtrl.text.trim();
    final descripcion = descripcionCtrl.text.trim();
    final precioText = precioCtrl.text.trim();

    if (productName.isEmpty || descripcion.isEmpty || precioText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final precio = int.tryParse(precioText);
    if (precio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid price')));
      return;
    }

    final itemData = {
      'product_name': productName,
      'descripcion': descripcion,
      'precio': precio,
    };

    context
        .read<ApiCubit>()
        .updateItem(
          widget.itemToEdit.id,
          itemData,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
        )
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item updated')));
          context.go('/');
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating item: $error')),
          );
          print('Error updating item: $error');
        });
  }
}
