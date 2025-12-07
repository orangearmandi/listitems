part of 'preference_cubit.dart';

abstract class PreferenceState extends Equatable {
  const PreferenceState();

  @override
  List<Object> get props => [];
}

class PreferenceInitial extends PreferenceState {}

class PreferenceLoaded extends PreferenceState {
  final List<SavedItem> items;

  const PreferenceLoaded(this.items);

  @override
  List<Object> get props => [items];
}
