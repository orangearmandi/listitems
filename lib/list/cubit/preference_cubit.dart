import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../model/saved_item.dart';

part 'preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  late Box<SavedItem> _box;

  PreferenceCubit() : super(PreferenceInitial()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<SavedItem>('savedItems');
    loadItems();
  }

  void loadItems() {
    final items = _box.values.toList();
    emit(PreferenceLoaded(items));
  }

  Future<void> addItem(SavedItem item) async {
    await _box.put(item.id, item);
    loadItems();
  }

  Future<void> updateItem(String id, SavedItem item) async {
    await _box.put(id, item);
    loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    loadItems();
  }
}
