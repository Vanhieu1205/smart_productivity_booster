import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String securityQuestion;
  final String securityAnswer;

  const RegisterRequested(
    this.username,
    this.email,
    this.password,
    this.securityQuestion,
    this.securityAnswer,
  );

  @override
  List<Object?> get props => [username, email, password, securityQuestion, securityAnswer];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdateUserRequested extends AuthEvent {
  final String? newUsername;
  final String? newAvatarPath;
  const UpdateUserRequested({this.newUsername, this.newAvatarPath});
  @override
  List<Object?> get props => [newUsername, newAvatarPath];
}

class CheckSecurityQuestionRequested extends AuthEvent {
  final String email;
  const CheckSecurityQuestionRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class VerifySecurityAnswerRequested extends AuthEvent {
  final String email;
  final String answer;
  const VerifySecurityAnswerRequested(this.email, this.answer);
  @override
  List<Object?> get props => [email, answer];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String newPassword;
  const ResetPasswordRequested(this.email, this.newPassword);
  @override
  List<Object?> get props => [email, newPassword];
}
