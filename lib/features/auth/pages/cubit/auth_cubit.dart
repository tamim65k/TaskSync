import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_offline_first/core/constants/services/sp_service.dart';
import 'package:task_offline_first/features/auth/pages/repository/auth_local_repository.dart';
import 'package:task_offline_first/features/auth/pages/repository/auth_remote_repository.dart';
import 'package:task_offline_first/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  void getUserData() async {
    try {
      emit(AuthLoading());
      print('AuthCubit: Trying to fetch user from remote');
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);
        print('AuthCubit: Got user from remote, emitting AuthLoggedIn');
        emit(AuthLoggedIn(userModel));
        return;
      }
      print('AuthCubit: No user from remote, emitting AuthInitial');
      emit(AuthInitial());
    } catch (e) {
      print('AuthCubit: Remote fetch failed: $e');
      // If remote fails, try local
      final localUser = await authLocalRepository.getUser();
      final token = await spService.getToken();
      print('AuthCubit: Local user: $localUser, token: $token');
      if (localUser != null && token != null && token.isNotEmpty) {
        print('AuthCubit: Found local user and token, emitting AuthLoggedIn');
        emit(AuthLoggedIn(localUser.copyWith(token: token)));
      } else {
        print('AuthCubit: No local user or token, emitting AuthInitial');
        emit(AuthInitial());
      }
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }

      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
