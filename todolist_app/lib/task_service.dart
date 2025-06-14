import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task.dart';

// Ganti ini dengan URL ngrok kamu jika berubah
const String baseUrl = 'https://2dd8-27-124-95-83.ngrok-free.app/api/tasks';

class TaskService {
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Ambil semua task
  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat tugas. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data tugas: $e');
    }
  }

  /// Tambah task baru
  Future<void> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
          'Gagal menambahkan tugas. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menambahkan tugas: $e');
    }
  }

  /// Update task
  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('ID tugas tidak ditemukan untuk update.');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${task.id}'),
        headers: headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui tugas. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui tugas: $e');
    }
  }

  /// Hapus task
  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal menghapus tugas. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus tugas: $e');
    }
  }
}
