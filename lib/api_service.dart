import 'dart:convert';
import 'package:flutter_todo_app/todo.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://mobileproject2.000webhostapp.com/";

  Future<List<ToDo>> fetchToDos() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}get_todo.php"));

      if (response.statusCode == 200) {
        final List<dynamic> todoListJson = json.decode(response.body)['todos'];
        return todoListJson.map((json) => ToDo.fromJson(json)).toList();
      } else {
        print('Failed to fetch todos - ${response.statusCode}');
        return []; // Return an empty list or handle the error accordingly
      }
    } catch (e) {
      print('Error fetching todos: $e');
      return []; // Return an empty list or handle the error accordingly
    }
  }

  Future<ToDo> addNewToDo(String todoText) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'todoText': todoText, 'isDone': 'false'};

    try {
      var response = await http.post(
        Uri.parse("${baseUrl}add_todo.php"),
        headers: headers,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = json.decode(response.body)['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      print('Error adding todo: $e');
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<ToDo> updateToDoStatus(String todoText, String todoId, bool isDone) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'todoText': todoText, 'isDone': isDone.toString(), 'id': todoId};

    try {
      var response = await http.post(
        Uri.parse("${baseUrl}update_todo.php"),
        headers: headers,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = json.decode(response.body)['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to edit todo');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to edit todo: $e');
    }
  }

  Future<ToDo> deleteToDo(String todoId) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'id': todoId};

    try {
      var response = await http.post(
        Uri.parse("${baseUrl}delete_todo.php"),
        headers: headers,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = json.decode(response.body)['todo'];
        return ToDo.fromJson(todoJson);
      } else {
        throw Exception('Failed to delete todo');
      }
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
