import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task.dart';
import 'task_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TaskService _taskService = TaskService();
  late Future<List<Task>> _tasksFuture;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedTimeString; // Tambahan
  int? _editingTaskId;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks();
    });
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks().catchError((error) {
        throw error;
      });
    });
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _selectedTimeString = null;
    _editingTaskId = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedTimeString = _selectedTime!.format(context);
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      _showErrorSnackbar('Judul tidak boleh kosong');
      return;
    }
    if (_selectedDate == null) {
      _showErrorSnackbar('Tanggal harus dipilih');
      return;
    }

    String? timeString;
    if (_selectedTime != null) {
      timeString = _selectedTime!.format(context);
    } else if (_selectedTimeString != null) {
      timeString = _selectedTimeString;
    } else {
      _showErrorSnackbar('Waktu harus dipilih');
      return;
    }

    Task task = Task(
      id: _editingTaskId,
      title: _titleController.text,
      description: _descController.text,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      time: timeString,
      isDone: false,
    );

    try {
      if (_editingTaskId == null) {
        await _taskService.createTask(task);
        _showSuccessSnackbar('Tugas berhasil ditambahkan');
      } else {
        await _taskService.updateTask(task);
        _showSuccessSnackbar('Tugas berhasil diperbarui');
      }
      _clearForm();
      _refreshTasks();
    } catch (e) {
      _showErrorSnackbar('Gagal menyimpan tugas: ${e.toString()}');
    }
  }

  void _editTask(Task task) {
    _titleController.text = task.title;
    _descController.text = task.description ?? '';
    _selectedDate = task.date != null ? DateTime.parse(task.date!) : null;
    _selectedTime = null;
    _selectedTimeString = task.time;
    _editingTaskId = task.id;
    setState(() {});
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _taskService.deleteTask(id);
      _showSuccessSnackbar('Tugas berhasil dihapus');
      _refreshTasks();
    } catch (e) {
      _showErrorSnackbar('Gagal menghapus tugas: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form input
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectDate(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today, size: 18),
                                SizedBox(width: 8),
                                Text(_selectedDate == null
                                    ? 'Pilih Tanggal'
                                    : DateFormat('dd-MM-yyyy').format(_selectedDate!)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectTime(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : (_selectedTimeString ?? 'Pilih Waktu'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_editingTaskId == null ? 'TAMBAH' : 'UPDATE'),
                          ),
                        ),
                        if (_editingTaskId != null) ...[
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _clearForm();
                                setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('BATAL'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // List Tugas
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return Center(child: Text('Belum ada tugas'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description != null) Text(task.description!),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16),
                                  SizedBox(width: 4),
                                  Text(task.date ?? '-'),
                                  SizedBox(width: 16),
                                  Icon(Icons.access_time, size: 16),
                                  SizedBox(width: 4),
                                  Text(task.time ?? '-'),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editTask(task),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
