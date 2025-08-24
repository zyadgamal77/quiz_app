import 'package:quiz_app/model/question.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(Map<String, dynamic> map, Map<String, dynamic> data) {
    return Quiz(
      id: map['id'],
      title: map['title'] ?? "",
      categoryId: map['categoryId'] ?? "",
      timeLimit: map['timeLimit'] ?? 0,
      questions: ((map['questions'] ?? []) as List)
          .map((e) => Question.fromMap(e))
          .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now(),
      if(!isUpdate) 'updateAt' : DateTime.now(),
      'createdAt' :createdAt,
    };
  }

  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timeLimit,
    List<Question>? questions,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
    );
  }
}
