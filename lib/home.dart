import 'dart:developer';
import 'package:flutter/material.dart';
import 'todo.dart';
import 'colors.dart';
import 'api_service.dart';
import 'todo_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _apiService = ApiService();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  bool _loading = true;
  String _errorMessage = '';
  bool _addingTodo = false;

  @override
  void initState() {
    //_foundToDo = todosList;
    _fetchToDos();
    super.initState();
  }

  Future<void> _fetchToDos() async {
    try {
      final todos = await _apiService.fetchToDos();
      setState(() {
        _foundToDo = todos;
        _loading = false;
        _errorMessage = ''; // Clear any previous error messages
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error fetching todos: $e';
      });
      // Handle error, show an error message or log the error
      print(_errorMessage);
    }
  }

  Future<void> _addToDoItem(String toDo) async {
    log(toDo.toString());

    if (toDo.isEmpty || toDo == "") {
      _showErrorMessage("Please Enter Todo Text");
      return;
    }

    try {
      setState(() {
        _addingTodo = true;
      });
      final newToDo = await _apiService.addNewToDo(toDo);
      setState(() {
        _foundToDo.add(newToDo); // Add the new todo to the list
        _loading = false; // Hide loading indicator
        _todoController.clear(); // Clear the text field
      });
      _showSuccessMessage('Todo added successfully');
    } catch (e) {
      // show an error message or log the error
      _showErrorMessage('Failed to add todo: $e');
    } finally {
      setState(() {
        _addingTodo = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage.isNotEmpty
                          ? Center(child: Text(_errorMessage))
                          : _foundToDo.isEmpty
                          ? const Center(child: Text('No data found'))
                          : const SizedBox.shrink(),
                      for (ToDo todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdBlue,
                    minimumSize: const Size(60, 60),
                    elevation: 10,
                  ),
                  child: _addingTodo
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async {
    try {
      // Toggle the isDone property
      todo.isDone = !todo.isDone!;

      // Call the API to update isDone
      await _apiService.updateToDoStatus(todo.todoText, todo.id, todo.isDone!);

      setState(() {
        _loading = false; // Hide loading indicator
      });
    } catch (e) {
      setState(() {
        _loading = false; // Hide loading indicator in case of an error
      });

      _showErrorMessage('Error updating todo status: $e');
      // show an error message
      print('Error updating todo status: $e');
    }
  }

  void _deleteToDoItem(String id) async {
    try {
      await _apiService.deleteToDo(id);
      setState(() {
        _foundToDo.removeWhere(
                (todo) => todo.id == id); // Remove the todo from the list
        _originalToDoList.removeWhere(
                (todo) => todo.id == id); // Remove from the original list
        _loading = false; // Hide loading indicator

        _runFilter("");
      });
      _todoController.clear();

      _showSuccessMessage('Todo deleted successfully');
    } catch (e) {
      _showErrorMessage('Error deleting todo: $e');

      // Handle error, show an error message or log the error
      print('Error deleting todo: $e');
    }
  }

  final List<ToDo> _originalToDoList = [];

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];

    if (_originalToDoList.isEmpty) {
      _originalToDoList.addAll(_foundToDo);
    }

    if (enteredKeyword.isEmpty) {
      results = _originalToDoList;
    } else {
      results = _foundToDo
          .where((item) => item.todoText
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Icon(
          Icons.menu,
          color: tdBlack,
          size: 30,
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/avatar.jpeg'),
          ),
        ),
      ]),
    );
  }
}
