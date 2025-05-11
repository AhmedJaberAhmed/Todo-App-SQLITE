import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/database_services.dart';

class CompletedTasksPage extends StatelessWidget {
  final DatabaseServices _databaseServices = DatabaseServices.instance;

  CompletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completed Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.amber.shade50,
      body: FutureBuilder(
        future: _databaseServices.getTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No completed tasks!",
                style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          final completedTasks = snapshot.data!.where((task) => task.status == 1).toList();

          if (completedTasks.isEmpty) {
            return Center(
              child: Text(
                "No completed tasks!",
                style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              Task task = completedTasks[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.1),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.blue.withOpacity(0.3),
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
                      contentPadding: const EdgeInsets.all(16),
                      leading: task.status == 1
                          ? Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            )
                          : null,
                      title: Text(
                        task.content,
                        style: GoogleFonts.robotoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: task.status == 1 ? Colors.black : Colors.black,
                          decoration: task.status == 1
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: task.status == 1
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
