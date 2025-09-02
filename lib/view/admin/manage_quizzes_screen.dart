import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/model/quiz.dart';
import 'package:quiz_app/view/admin/edit_quiz_screen.dart';
import '../../model/category.dart';
import '../../theme/theme.dart';
import 'add_quiz_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ManageQuizzesScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? selectedCategoryId;
  List<Category> _categories = <Category>[];
  Category? _initialCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot = await _firestore
          .collection('categories')
          .where('ownerId', isEqualTo: uid)
          .get();
      final loadedCategories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = loadedCategories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(id: '', name: 'Unknown', description: '', ownerId: ''),
          );
          _selectedCategoryId = _initialCategory!.id;
          selectedCategoryId = _selectedCategoryId;
        }
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    Query query = _firestore.collection('quizzes').where('ownerId', isEqualTo: uid);
    final String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where('categoryId', isEqualTo: filterCategoryId);
    }

    // Text search is handled client-side below on the loaded list using the title field.

    return query.snapshots();
  }

  Widget _bulidTitle() {
    final String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return const Center(
        child: Text(
          'All Quizzes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('categories').doc(categoryId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text(
            'Loading...',
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }

        final category = Category.fromMap(
          categoryId,
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _bulidTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuizScreen(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'Search Quizzes',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 18,
                ),
                border: OutlineInputBorder(),
                hintText: 'Category',
              ),
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Categories')),
                if (_initialCategory != null &&
                    _categories.every((c) => c.id != _initialCategory!.id))
                  DropdownMenuItem(
                    value: _initialCategory!.id,
                    child: Text(_initialCategory!.name),
                  ),
                ..._categories.map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('An Error Occurred: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }
                final quizzes = snapshot.data!.docs
                    .map<Quiz?>((doc) {
                      try {
                        final data = doc.data() as Map<String, dynamic>;
                        return Quiz.fromMap({'id': doc.id, ...data},);
                      } catch (e) {
                        print('Error parsing quiz ${doc.id}: $e');
                        return null;
                      }
                    })
                    .where((quiz) => quiz != null)
                    .cast<Quiz>()
                    .where(
                      (quiz) =>
                          _searchController.text.isEmpty ||
                          quiz.title.toLowerCase().contains(_searchQuery),
                    )
                    .toList();
                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                        const Icon(
                          Icons.quiz_outlined,
                          color: AppTheme.secondaryColor,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No quizzes yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddQuizScreen(
                                  categoryId: widget.categoryId,
                                  categoryName: widget.categoryName,
                                ),
                              ),
                            );
                          },
                          child: const Text('Add Quiz'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.question_answer_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text('${quiz.questions.length} Questions'),
                                const SizedBox(width: 16),
                                const Icon(Icons.timer_outlined, size: 20),
                                const SizedBox(width: 4),
                                Text('${quiz.timeLimit} Min'),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.edit_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text('Edit'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.delete_outlined,
                                  color: Colors.redAccent,
                                ),
                                title: Text('delete'),
                              ),
                            ),
                          ],
                          onSelected: (value) =>
                              _handleQuizAction(context, value, quiz),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
    BuildContext context,
    String value,
    Quiz quiz,
  ) async {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditQuizScreen(quiz: quiz)),
      );
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Quiz'),
          content: const Text('Are you sure you want to delete this quiz?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection('quizzes').doc(quiz.id).delete();
      }
    }
  }
}
