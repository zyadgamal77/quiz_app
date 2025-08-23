import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/model/quiz.dart';

import '../../model/question.dart';
import '../../theme/theme.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}
class QuestionFormItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsControllers;
  int correctOptionIndex;
  QuestionFormItem({
    required this.questionController,
    required this.optionsControllers,
    required this.correctOptionIndex,
  });
  void dispose() {
    questionController.dispose();
    optionsControllers.forEach((element){
      element.dispose();
    });
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController ;
  late TextEditingController _timeLimitController ;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late List<QuestionFormItem> _questionItems;
  String? _selectedCategoryId;
  @override
  void initState() {
    super.initState();
    _initData();
  }
  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController = TextEditingController(text: widget.quiz.timeLimit.toString());
    _selectedCategoryId = widget.quiz.categoryId;
    _questionItems = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        questionController: TextEditingController(text: question.text),
        optionsControllers: question.options.map((option) => 
          TextEditingController(text: option)
        ).toList(),
        correctOptionIndex: question.correctOptionIndex,
      );
    }).toList();
  }
void _addQuestion() {
  setState(() {
    _questionItems.add(
      QuestionFormItem(
        questionController: TextEditingController(),
        optionsControllers: List.generate(4, (_) =>
            TextEditingController(),),
        correctOptionIndex: 0,
      ),
    );
  });
}
void _removeQuestion(int index) {
  if (_questionItems.length > 1) { // Don't remove the last question
    setState(() {
      // Dispose the controllers before removing
      _questionItems[index].dispose();
      _questionItems.removeAt(index);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The quiz must contain at least one question')),
    );
  }
}
  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions = _questionItems.map((item) => Question(
        text: item.questionController.text.trim(),
        options: item.optionsControllers.map((e) => e.text.trim()).toList(),
        correctOptionIndex: item.correctOptionIndex,
      )).toList();

      final updatedQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.tryParse(_timeLimitController.text) ?? 1,
        questions: questions,
      );

      await _firestore
          .collection('quizzes')
          .doc(widget.quiz.id)
          .update(updatedQuiz.toMap());

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz updated successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quiz: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          "Edit Quiz",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quiz title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Time Limit Field
            TextFormField(
              controller: _timeLimitController,
              decoration: const InputDecoration(
                labelText: 'Time Limit (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time limit';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Questions Section
            ..._questionItems.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_questionItems.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeQuestion(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: question.questionController,
                        decoration: const InputDecoration(
                          labelText: 'Question',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a question';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ...question.optionsControllers.asMap().entries.map((entry) {
                        final optionIndex = entry.key;
                        final controller = entry.value;
                        return ListTile(
                          leading: Radio<int>(
                            value: optionIndex,
                            groupValue: question.correctOptionIndex,
                            onChanged: (value) {
                              setState(() {
                                question.correctOptionIndex = value!;
                              });
                            },
                          ),
                          title: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Option ${optionIndex + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter option text';
                              }
                              return null;
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
            
            // Add Question Button
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Update Quiz',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
