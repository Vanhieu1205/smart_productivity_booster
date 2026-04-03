import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthSecurityQuestionLoaded extends AuthState {
  final String email;
  final String question;
  const AuthSecurityQuestionLoaded({required this.email, required this.question});
  @override
  List<Object?> get props => [email, question];
}

class AuthSecurityAnswerVerified extends AuthState {
  final String email;
  const AuthSecurityAnswerVerified({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSuccess extends AuthState {}
