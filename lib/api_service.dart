import 'dart:developer';

import 'package:dio/dio.dart';

import 'todo.dart';

class ApiService {
  final Dio _dio = Dio();
  var baseUrl = "https://mobileproject2.000webhostapp.com/";
  Future<List<ToDo>> fetchToDos() async {
    try {
      final response = await _dio.get(
          "${baseUrl}get_todo.php"); // Replace with your actual API endpoint

      if (response.statusCode == 200) {
        final List<dynamic> todoListJson = response.data['todos'];
        return todoListJson.map((json) => ToDo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch todos');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to fetch todos: $e');
    }
  }

  Future<ToDo> addNewToDo(String todoText) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'todoText': todoText, 'isDone': 'false'};
    try {
      var response = await _dio.request(
        "${baseUrl}add_todo.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = response.data['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<ToDo> updateToDoStatus(
      String todoText, String todoId, bool isDone) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {
      'todoText': todoText,
      'isDone': isDone,
      'id': todoId,
    };
    try {
      var response = await _dio.request(
        "${baseUrl}update_todo.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = response.data['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to edit todo');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to edit todo: $e');
    }
  }

  Future<ToDo> deleteToDo(String todoId) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {
      'id': todoId,
    };
    try {
      var response = await _dio.request(
        "${baseUrl}delete_todo.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = response.data['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }
}
