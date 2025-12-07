import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/apitcubit.dart';

import '../cubit/preference_cubit.dart';

import '../model/saved_item.dart';
import '../../core/constant/nameslabel.dart';

// --- PrefsNewPage ---

class PrefsNewPage extends StatefulWidget {
  final SavedItem? itemToEdit;
  const PrefsNewPage({super.key, this.itemToEdit});

  @override
  State<PrefsNewPage> createState() => _PrefsNewPageState();
}

class _PrefsNewPageState extends State<PrefsNewPage> {
  final TextEditingController customNameCtrl = TextEditingController();
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController descripcionCtrl = TextEditingController();
  final TextEditingController precioCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      customNameCtrl.text = widget.itemToEdit!.name;
      productNameCtrl.text =
          widget.itemToEdit!.description; // assuming description is productName
      descripcionCtrl.text = widget.itemToEdit!.description;
      precioCtrl.text = ''; // no price in SavedItem
      // image not handled for edit
    }
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
        title: Text(
          widget.itemToEdit != null ? editItemLabel : createNewItemLabel,
          style: const TextStyle(color: Colors.white),
        ),
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
                      controller: customNameCtrl,
                      decoration: InputDecoration(
                        labelText: CustomNameFieldLabel,
                        prefixIcon: const Icon(Icons.label),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descripcionCtrl,
                      decoration: InputDecoration(
                        labelText: descriptionFieldLabel,
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    if (widget.itemToEdit == null) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: productNameCtrl,
                        decoration: InputDecoration(
                          labelText: productNameFieldLabel,
                          prefixIcon: const Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: precioCtrl,
                        decoration: InputDecoration(
                          labelText: priceFieldLabel,
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.itemToEdit == null) ...[
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
                      Text(
                        selectImageLabel,
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
                            label: Text(pickImageLabel),
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
            ],
            const SizedBox(height: 20),
            BlocBuilder<ApiCubit, ApiState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is! ApiLoading ? _submitItem : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: state is ApiLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.itemToEdit != null
                              ? 'Actualizar y Guardar'
                              : 'Crear y Guardar',
                        ),
                );
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text(cancelButtonLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _submitItem() {
    final customName = customNameCtrl.text.trim();
    final descripcion = descripcionCtrl.text.trim();

    if (customName.isEmpty || descripcion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorsLabelFillalFields)));
      return;
    }

    if (widget.itemToEdit != null) {
      // Edit local item
      final updatedItem = SavedItem(
        id: widget.itemToEdit!.id,
        name: customName,
        description: descripcion,
        image: widget.itemToEdit!.image,
        imageUrl: widget.itemToEdit!.imageUrl,
        created: widget.itemToEdit!.created,
        updated: DateTime.now(),
      );
      context.read<PreferenceCubit>().updateItem(
        widget.itemToEdit!.id,
        updatedItem,
      );
      context.go('/');
    } else {
      // Create new
      final productName = productNameCtrl.text.trim();
      final precioText = precioCtrl.text.trim();

      if (productName.isEmpty || precioText.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorsLabelFillalFields)));
        return;
      }

      final precio = int.tryParse(precioText);
      if (precio == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Precio inválido')));
        return;
      }

      final itemData = {
        'product_name': productName,
        'descripcion': descripcion,
        'precio': precio,
      };

      context
          .read<ApiCubit>()
          .createItem(itemData, imageFile: _imageFile, imageBytes: _imageBytes)
          .then((_) {
            final state = context.read<ApiCubit>().state;
            if (state is ApiLoaded && state.items.isNotEmpty) {
              final newItem = state.items.first;
              final savedItem = SavedItem(
                id: newItem.id,
                name: customName,
                description: newItem.description,
                image: newItem.image,
                imageUrl: newItem.image,
                created: newItem.createdDate,
                updated: newItem.updatedDate,
              );
              context.read<PreferenceCubit>().addItem(savedItem);
              context.go('/');
            }
          })
          .catchError((error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $error')));
            print('Error creating item: $error');
          });
    }
  }
}
