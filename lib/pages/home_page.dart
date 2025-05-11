import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 import '../models/task.dart';
import '../services/database_services.dart';
import 'CompletedTasksPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _task;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CompletedTasksPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: _addTaskButton(),
      backgroundColor: Colors.amber.shade50,
      body: _tasksList(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      backgroundColor: Colors.amber,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Add Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      cursorColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          _task = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        hintText: 'Type your task...',
                        labelStyle: TextStyle(color: Colors.grey),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.amber, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                              color: Colors.amberAccent, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        filled: true,
                        fillColor: Colors.amber.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      color: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Add Task",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_task == null || _task!.isEmpty) return;

                          _databaseServices.addTask(_task!);
                          setState(() {
                             _task = null;
                          });
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                ),
              )),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
        future: _databaseServices.getTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No tasks yet!",
                style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.2),
                child: InkWell(
                  onTap: () {},
                  onLongPress: () {
                    _databaseServices.deleteTask(task.id);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.blue.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      title: Text(
                        task.content,
                        style: GoogleFonts.robotoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: task.status == 1 ? Colors.black : Colors.black,
                          letterSpacing: 1.2,
                          decoration: task.status == 1 ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: CupertinoCheckbox(
                        activeColor: Colors.amber,
                        value: task.status == 1,
                        onChanged: (value) {
                          _databaseServices.updateTaskStatus(
                              task.id, value == true ? 1 : 0);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
