import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_offline_first/core/constants/constants.dart';
import 'package:task_offline_first/core/constants/services/sp_service.dart';
import 'package:task_offline_first/features/auth/pages/repository/auth_local_repository.dart';
import 'package:task_offline_first/models/user_model.dart';

class AuthRemoteRepository {
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        print('AuthRemoteRepository: No token found');
        return null;
      }

      print('AuthRemoteRepository: Checking token validity');
      final res = await http
          .post(
            Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
            headers: {'Content-Type': 'application/json', 'auth-token': token},
          )
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              print('AuthRemoteRepository: tokenIsValid request timed out');
              throw Exception('Network timeout');
            },
          );

      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        print('AuthRemoteRepository: Token invalid or status not 200');
        return null;
      }

      print('AuthRemoteRepository: Fetching user data');
      final userResponse = await http
          .get(
            Uri.parse('${Constants.backendUri}/auth'),
            headers: {'Content-Type': 'application/json', 'auth-token': token},
          )
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              print('AuthRemoteRepository: user data request timed out');
              throw Exception('Network timeout');
            },
          );

      if (userResponse.statusCode != 200) {
        print('AuthRemoteRepository: User fetch failed');
        throw jsonDecode(userResponse.body)['msg'];
      }

      print('AuthRemoteRepository: User fetch succeeded');
      return UserModel.fromJson(userResponse.body);
    } catch (e) {
      print('AuthRemoteRepository: Exception caught: $e');
      final user = await authLocalRepository.getUser();
      return user;
    }
  }
}
