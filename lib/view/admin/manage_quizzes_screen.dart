import 'dart:math';

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

  String _searchQuery = '';
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
    try{
      final querySnapshot = await _firestore.collection('categories').get();
      final categories = querySnapshot.docs.map((doc) =>
          Category.fromMap(doc.id, doc.data())).toList();
      setState(() {
        this.categories = categories;
      });

  } catch(e){
      print("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
