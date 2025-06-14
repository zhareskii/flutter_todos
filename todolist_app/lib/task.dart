class Task {
  int? id;
  String title;
  String? description;
  String? date;
  String? time;
  bool isDone;

  Task({
    this.id,
    required this.title,
    this.description,
    this.date,
    this.time,
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      time: json['time'],
      isDone: json['is_done'] == 1 || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'is_done': isDone ? 1 : 0,
    };
  }
}
