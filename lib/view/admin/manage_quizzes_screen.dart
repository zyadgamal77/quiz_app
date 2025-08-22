import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/category.dart';
import '../../theme/theme.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? categoryId;

  const ManageQuizzesScreen({super.key, this.categoryId});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  final String _searchQuery = '';
  String? _selectedCategoryId;
  String? selectedCategoryId;
  List<Category> categories = <Category>[];
  Category? _initialCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      final loadedCategories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        categories = loadedCategories;
        if (widget.categoryId != null) {
          _initialCategory = categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(id: '', name: "Unknown", description: ''),
          );
          _selectedCategoryId = _initialCategory!.id;
          selectedCategoryId = _selectedCategoryId;
        }
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection('quizzes');
    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where('categoryId', isEqualTo: filterCategoryId);
    }

    if (_searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: _searchQuery);
    }

    return query.snapshots();
  }

  Widget _bulidTitle() {
    String? categoyId = _selectedCategoryId ?? widget.categoryId;
    if (categoyId == null) {
      return Text("All Quizzes", style: TextStyle(fontWeight: FontWeight.bold));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("categories").doc(categoyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "Loading...",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }

        final category = Category.fromMap(
          categoyId,
          snapshot.data!.data() as Map<String, dynamic>,
        );
        
        return Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Quizzes')),
      body: Column(
        children: [
          // Add your UI widgets here
        ],
      ),
    );
  }
}
