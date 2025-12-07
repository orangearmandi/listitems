import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:dio/dio.dart';

import 'dart:io';
import 'dart:typed_data';
import '../model/item.dart';
import '../../config/configuration.dart';

part 'api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  ApiCubit() : super(ApiInitial());
  final String _baseEndpoint =
      ConfigurationApiList().config.endpoints.listItems;
  final Dio _dio = Dio();

  Future<void> fetchItems() async {
    emit(ApiLoading());
    try {
      final response = await _dio.get(_baseEndpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        final apiResponse = ApiResponse.fromJson(data);
        emit(ApiLoaded(apiResponse.items));
      } else {
        emit(ApiError('Failed to load items: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> createItem(
    Map<String, dynamic> itemData, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    emit(ApiLoading());
    try {
      final formData = FormData.fromMap(itemData);
      if (imageFile != null) {
        formData.files.add(
          MapEntry('imagen', await MultipartFile.fromFile(imageFile.path)),
        );
      } else if (imageBytes != null) {
        formData.files.add(
          MapEntry(
            'imagen',
            MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
          ),
        );
      }
      final response = await _dio.post(_baseEndpoint, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final item = Item.fromJson(data);
        emit(ApiLoaded([item]));
      } else {
        emit(ApiError('Failed to create item: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    emit(ApiLoading());
    try {
      final response = await _dio.delete('$_baseEndpoint/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local state
        final currentState = state;
        if (currentState is ApiLoaded) {
          final updatedItems = currentState.items
              .where((item) => item.id != id)
              .toList();
          emit(ApiLoaded(updatedItems));
        }
      } else {
        emit(ApiError('Failed to delete item'));
      }
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> updateItem(
    String id,
    Map<String, dynamic> itemData, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    emit(ApiLoading());
    try {
      final formData = FormData.fromMap(itemData);
      if (imageFile != null) {
        formData.files.add(
          MapEntry('imagen', await MultipartFile.fromFile(imageFile.path)),
        );
      } else if (imageBytes != null) {
        formData.files.add(
          MapEntry(
            'imagen',
            MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
          ),
        );
      }
      final response = await _dio.patch('$_baseEndpoint/$id', data: formData);
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refetch items to update the list
        await fetchItems();
      } else {
        emit(ApiError('Failed to update item: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }
}
