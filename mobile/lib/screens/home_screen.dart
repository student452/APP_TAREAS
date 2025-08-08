import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'login_screen.dart';
import 'new_task.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String authToken; // Recibimos el token de autenticación desde el login

  const HomeScreen({
    super.key,
    required this.userName,
    required this.authToken,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TaskService _taskService; // Instancia del servicio de tareas
  List<Task> _tasks = []; // Lista de tareas a mostrar
  bool _isLoadingTasks = false; // Estado de carga de tareas
  String? _errorMessage; // Mensaje de error

  @override
  void initState() {
    super.initState();
    // Inicializamos TaskService con el token de autenticación
    _taskService = TaskService(widget.authToken);
    _fetchTasks(); // Cargamos las tareas al iniciar la pantalla
  }

  // Método para cargar las tareas
  Future<void> _fetchTasks() async {
    setState(() {
      _isLoadingTasks = true;
      _errorMessage = null; // Limpiamos cualquier error anterior
    });
    try {
      final fetchedTasks = await _taskService.fetchTasks();
      // Ordenar las tareas: primero las nuevas
      fetchedTasks.sort((a, b) {
        final DateTime dateA = a.updatedAt ?? a.createdAt;
        final DateTime dateB = b.updatedAt ?? b.createdAt;
        return dateB.compareTo(dateA);
      });
      setState(() {
        _tasks = fetchedTasks;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar tareas: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar tareas: $e')));
    } finally {
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  // Método para marcar una tarea como completada
  void _toggleTaskStatus(Task task) async {
    setState(() {
      _isLoadingTasks = true; // Muestra un indicador mientras se actualiza
    });
    try {
      // Si la tarea está COMPLETED, la marcamos como PENDING, si no, como COMPLETED
      final newStatus = task.status == TaskStatus.COMPLETED
          ? TaskStatus.PENDING
          : TaskStatus.COMPLETED;

      await _taskService.updateTask(
        task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
      );

      // Una vez actualizada en el backend, refrescamos la lista
      await _fetchTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tarea "${task.title}" actualizada a ${newStatus.toDisplayString()}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar tarea: $e')));
    } finally {
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  // Método para editar una tarea
  void _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(
          taskService: _taskService,
          taskToEdit: task, // Pasamos la tarea a editar
        ),
      ),
    );
    if (result == true) {
      // Si la tarea fue editada/creada exitosamente
      _fetchTasks(); // Refrescar la lista de tareas
    }
  }

  // Método para eliminar una tarea
  void _deleteTask(String taskId, String taskTitle) async {
    // Confirmación antes de eliminar
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la tarea "$taskTitle"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoadingTasks = true;
      });
      try {
        await _taskService.deleteTask(taskId);
        await _fetchTasks(); // Refrescar la lista después de eliminar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea "$taskTitle" eliminada con éxito.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar tarea: $e')));
      } finally {
        setState(() {
          _isLoadingTasks = false;
        });
      }
    }
  }

  // Método para navegar a la pantalla de crear nueva tarea
  void _goToNewTaskScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(taskService: _taskService),
      ),
    );
    if (result == true) {
      // Si se creó una nueva tarea exitosamente, refrescar la lista
      _fetchTasks();
    }
  }

  // Método para cerrar sesión
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.userName}!'),
        backgroundColor: const Color.fromARGB(255, 98, 151, 244),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar Tareas',
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFBBDEFB)],
          ),
        ),
        child: _isLoadingTasks
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchTasks,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            : _tasks.isEmpty
            ? const Center(
                child: Text(
                  'No hay tareas. ¡Crea una nueva!',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: Checkbox(
                        value: task.status == TaskStatus.COMPLETED,
                        onChanged: (bool? newValue) {
                          _toggleTaskStatus(task);
                        },
                        activeColor: task.status
                            .toColor(), // Color del checkbox basado en el estado
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: task.status == TaskStatus.COMPLETED
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.blueGrey[600]),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: task.status
                                  .toColor(), // Color de fondo basado en el estado
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.status.toDisplayString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (task.updatedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Actualizado: ${task.updatedAt!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Creado: ${task.createdAt.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => _editTask(task),
                            tooltip: 'Editar Tarea',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task.id, task.title),
                            tooltip: 'Eliminar Tarea',
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
      // Botón flotante para añadir nuevas tareas
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNewTaskScreen,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        tooltip: 'Crear Nueva Tarea',
        child: const Icon(Icons.add),
      ),
    );
  }
}
