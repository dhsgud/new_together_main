import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {}

class AppError extends AppState {
  final String message;

  const AppError({required this.message});

  @override
  List<Object> get props => [message];
}
