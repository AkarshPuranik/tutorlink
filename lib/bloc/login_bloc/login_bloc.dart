import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LoginBloc implementation
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitialState()) {
    // Handling Login event
    on<LoginUserEvent>((event, emit) async {
      try {
        CollectionReference loginCollection =
        FirebaseFirestore.instance.collection('login_details');
        CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

        // Perform Firestore query to validate login credentials
        var loginQuerySnapshot = await loginCollection
            .where("enrollment", isEqualTo: event.enrollmentNumber)
            .where("password", isEqualTo: event.password)
            .get();

        if (loginQuerySnapshot.docs.isNotEmpty) {
          // Fetch user details from Firestore
          var userQuerySnapshot = await usersCollection
              .where("enrollment", isEqualTo: event.enrollmentNumber)
              .get();

          if (userQuerySnapshot.docs.isNotEmpty) {
            var user =
            await usersCollection.doc(userQuerySnapshot.docs[0].id).get();
            var userDetails = user.data() as Map<String, dynamic>;

            // Emit success state after successfully fetching user details
            emit(const LoginSuccessState());
          } else {
            emit(const LoginErrorState(errorMessage: "User not found"));
          }
        } else {
          emit(const LoginErrorState(errorMessage: "Invalid login credentials"));
        }
      } catch (e) {
        emit(LoginErrorState(errorMessage: e.toString()));
      }
    });

    // Handling Update User event
    on<UpdateUserEvent>((event, emit) async {
      try {
        CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

        // Update the user's information in Firestore
        await usersCollection.doc(event.userId).update({
          'enrollment': event.newEnrollmentNumber,
          'email': event.newEmail,
        });

        // Update the user's email and password in FirebaseAuth
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.updateEmail(event.newEmail);
          if (event.newPassword.isNotEmpty) {
            await currentUser.updatePassword(event.newPassword);
          }
        }

        emit(const UpdateUserSuccessState());
      } catch (e) {
        emit(UpdateUserErrorState(errorMessage: e.toString()));
      }
    });

    // Handling Forgot Password event
    on<ForgotPasswordEvent>((event, emit) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
        emit(const ForgotPasswordSuccessState());
      } catch (e) {
        emit(ForgotPasswordErrorState(errorMessage: e.toString()));
      }
    });
  }
}

// Define Events
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginUserEvent extends LoginEvent {
  final String enrollmentNumber;
  final String password;

  const LoginUserEvent(this.enrollmentNumber, this.password);

  @override
  List<Object> get props => [enrollmentNumber, password];
}

class UpdateUserEvent extends LoginEvent {
  final String userId;
  final String newEnrollmentNumber;
  final String newEmail;
  final String newPassword;

  const UpdateUserEvent(
      this.userId, this.newEnrollmentNumber, this.newEmail, this.newPassword);

  @override
  List<Object> get props =>
      [userId, newEnrollmentNumber, newEmail, newPassword];
}

class ForgotPasswordEvent extends LoginEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object> get props => [email];
}

// Define States
abstract class LoginState {
  const LoginState();
}

class LoginInitialState extends LoginState {
  const LoginInitialState();
}

class LoginSuccessState extends LoginState {
  const LoginSuccessState();
}

class LoginErrorState extends LoginState {
  final String errorMessage;

  const LoginErrorState({this.errorMessage = "Login failed"});
}

class UpdateUserSuccessState extends LoginState {
  const UpdateUserSuccessState();
}

class UpdateUserErrorState extends LoginState {
  final String errorMessage;

  const UpdateUserErrorState({this.errorMessage = "Update failed"});
}

class ForgotPasswordSuccessState extends LoginState {
  const ForgotPasswordSuccessState();
}

class ForgotPasswordErrorState extends LoginState {
  final String errorMessage;

  const ForgotPasswordErrorState({this.errorMessage = "Password reset failed"});
}
