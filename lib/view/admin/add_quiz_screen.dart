
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/model/category.dart';
import 'package:quiz_app/model/question.dart';
import 'package:quiz_app/theme/theme.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const AddQuizScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
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
    for (var element in optionsControllers) {
      element.dispose();
    }
  }
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  final List<QuestionFormItem> _questionFormItems = [];
  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    if (widget.categoryId == null) {
      _loadCategories();
    }
    _addQuestion();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _firestore
          .collection('categories')
          .where('ownerId', isEqualTo: uid)
          .orderBy('name')
          .get();
      setState(() {
        _categories = snapshot.docs
            .map(
              (doc) =>
                  Category.fromMap(doc.id, doc.data()),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _questionFormItems.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questionFormItems.length > 1) {
      // Don't remove the last question
      setState(() {
        // Dispose the controllers before removing
        _questionFormItems[index].dispose();
        _questionFormItems.removeAt(index);
      });
    } else {
      // Show a message that at least one question is required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The quiz must contain at least one question'),
        ),
      );
    }
  }

  Future<void> _saveQuiz() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_questionFormItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
        return;
      }

      if (widget.categoryId == null && _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Validate all questions and options
      for (var i = 0; i < _questionFormItems.length; i++) {
        final item = _questionFormItems[i];
        if (item.questionController.text.trim().isEmpty) {
          throw 'Question ${i + 1} is empty';
        }

        final options = item.optionsControllers
            .map((e) => e.text.trim())
            .toList();
        if (options.any((option) => option.isEmpty)) {
          throw 'All options for question ${i + 1} must be filled';
        }

        if (options.toSet().length != options.length) {
          throw 'Duplicate options found in question ${i + 1}';
        }
      }

      final questions = _questionFormItems
          .map(
            (item) => Question(
              text: item.questionController.text.trim(),
              options: item.optionsControllers
                  .map((e) => e.text.trim())
                  .toList(),
              correctOptionIndex: item.correctOptionIndex,
            ),
          )
          .toList();

      final quizData = {
        'title': _titleController.text.trim(),
        'categoryId': _selectedCategoryId,
        'timeLimit': int.tryParse(_timeLimitController.text) ?? 30,
        // Default to 30 seconds if parsing fails
        'questions': questions.map((q) => q.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': uid,
      };

      debugPrint('Saving quiz data: $quizData');

      await _firestore.collection('quizzes').add(quizData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving quiz: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}. Please check all fields and try again.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionFormItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName != null
              ? 'Add ${widget.categoryName} quiz'
              : 'Add Quiz',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quiz Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Category Dropdown (only show if not coming from a specific category)
                if (widget.categoryId == null) ...[
                  if (_isLoadingCategories)
                    const Center(child: CircularProgressIndicator())
                  else if (_categories.isEmpty)
                    const Text('No categories available')
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.category,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Select a category'),
                        ),
                        ..._categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            ,
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                ],

                // Quiz Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    hintText: 'Enter Quiz Title',
                    labelText: 'Quiz Title',
                    prefixIcon: const Icon(Icons.title, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quiz title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeLimitController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),
                    hintText: 'Enter Time Limit',
                    labelText: 'Time Limit (in minutes)',
                    prefixIcon: const Icon(Icons.timer, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty || value.isEmpty) {
                      return 'Please enter time limit';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid time limit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Questions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          label: const Text('Add Question'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._questionFormItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  if (_questionFormItems.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _removeQuestion(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: question.questionController,
                                decoration: const InputDecoration(
                                  labelText: 'Question title',
                                  hintText: 'Enter question title',
                                  prefixIcon: Icon(
                                    Icons.question_answer,
                                    color: AppTheme.primaryColor,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the question';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              ...question.optionsControllers.asMap().entries.map((
                                optionEntry,
                              ) {
                                final optionIndex = optionEntry.key;
                                final controller = optionEntry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        activeColor: AppTheme.primaryColor,
                                        value: optionIndex,
                                        groupValue: question.correctOptionIndex,
                                        onChanged: (value) {
                                          setState(() {
                                            question.correctOptionIndex =
                                                value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Option ${optionIndex + 1}',
                                            hintText: 'Enter option text',
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter option text';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ?  const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              :  const Text(
                                  'Save Quiz',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
