part of 'apitcubit.dart';

abstract class ApiState extends Equatable {
  const ApiState();

  @override
  List<Object> get props => [];
}

class ApiInitial extends ApiState {}

class ApiLoading extends ApiState {}

class ApiLoaded extends ApiState {
  final List<Item> items;

  const ApiLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ApiError extends ApiState {
  final String message;

  const ApiError(this.message);

  @override
  List<Object> get props => [message];
}
